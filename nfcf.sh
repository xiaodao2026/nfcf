#!/bin/bash
export LANG=zh_CN.UTF-8

#首页界面
#1、安装
#2、卸载

######安装部分#####
trim()
{
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

shell_name="nfcf"        #安装脚本的名字，使用时注意修改
this_name=`basename $0` #获取当前脚本名称(必须为.sh后缀)
#根据脚本名字后8位判断是安装模式，还是执行模式
if  [ "${this_name: -8}" != "_exec.sh" ] ; then
    #安装模式
    clear
    echo "Netflix自动域名切换"
    echo "YouTube频道：小道笔记"
    echo "https://www.youtube.com/channel/UCfSvDIQ8D_Zz62oAd5mcDDg"
    echo "--------------------------------"

    read -p "请选择执行模式(1 安装；2 卸载)：" mode
    if [ "${mode}" = '1' ] ; then
        #判断有没有${shell_name}_exec.sh 这个脚本(安装后实际执行的脚本名)
        if [ -f ~/bin/${shell_name}_exec.sh ] ; then  
            read -p "安装后的脚本已存在，是否覆盖(y/n)?" ctn
            #选择不覆盖则退出安装
            if [ "${ctn}" != 'y' ] ; then 
                exit
            fi
        fi
        mkdir -p ~/bin/
        read -p "输入你的CloudFlare注册账户邮箱（auth_email）:"  auth_email
        auth_email=`trim ${auth_email}`
        read -p "输入你的CloudFlare账户Globel ID（auth_key）:" auth_key
        auth_key=`trim ${auth_key}`
        read -p "输入你的主域名（zone_name）:"  zone_name
        zone_name=`trim ${zone_name}`
        read -p "输入你需要的完整的DDNS解析域名（record_name）:" record_name
        record_name=`trim ${record_name}`
        #read -p "输入A或AAAA及ipv4或ipv6解析（record_type）:"  record_type
        record_type="A"
	read -p "输入Netflix解锁优先级（110-140之间，数值越小运行的优先级越高，如主用机器配110，后备机配120）:" vps_flag
        vps_flag=`trim ${vps_flag}`

        echo "请确认你输入的参数"
        echo "auth_email:${auth_email}"
        echo "auth_key:${auth_key}"
        echo "zone_name:${zone_name}"
        echo "record_name:${record_name}"
        echo "record_type:${record_type}"
	echo "vps_flag:${vps_flag}"
        read -p "是否继续(y/n)?" ctn
        if [ "${ctn}" != 'y' ] ; then 
            exit
        fi
		echo "执行脚本为：~/bin/${shell_name}_exec.sh"
        #把当前脚本复制到~/bin目录，作为执行脚本
        cp $0 ~/bin/${shell_name}_exec.sh
        cd ~/bin/
		echo "下载Netflix解锁测试工具："
		wget -O nf https://github.com/sjlleo/netflix-verify/releases/download/2.01/nf_2.01_linux_amd64 && chmod +x nf 
        #替换变量
        sed -i 's|REPLACE_STR_auth_email|'"${auth_email}"'|' ${shell_name}_exec.sh
        sed -i 's|REPLACE_STR_auth_key|'"${auth_key}"'|' ${shell_name}_exec.sh
        sed -i 's|REPLACE_STR_zone_name|'"${zone_name}"'|' ${shell_name}_exec.sh
        sed -i 's|REPLACE_STR_record_name|'"${record_name}"'|' ${shell_name}_exec.sh
        sed -i 's|REPLACE_STR_record_type|'"${record_type}"'|' ${shell_name}_exec.sh
		sed -i 's|REPLACE_STR_vps_flag|'"${vps_flag}"'|' ${shell_name}_exec.sh
		
        exec_path=`pwd`
		echo "配置定时执行器,默认为20分钟执行一次，可通过crontab -e自行修改"
        crontab_list=`crontab -l 2>&1`
        if [ "${crontab_list:0:10}" = "no crontab" ] ;then #crontab 为空情况下,直接覆盖
            echo "*/20 * * * * sh ${exec_path}/${shell_name}_exec.sh >> ${exec_path}/${shell_name}_exec.log #DEAL_WORK_GREP_TAG" > conf_tmp && crontab conf_tmp && rm -f conf_tmp
        else #crontab 不为空情况下,保存原列表并追加新任务后再覆盖
			if [  `crontab -l |grep "DEAL_WORK_GREP_TAG" | grep exec.sh |wc -l` -gt 0 ] ; then
			    echo "已经有此crontab,请手工去确认crontab情况，不再自动添加！"
			else
                crontab -l > conf_tmp && echo "*/10 * * * * sh ${exec_path}/${shell_name}_exec.sh >> ${exec_path}/${shell_name}_exec.log #DEAL_WORK_GREP_TAG" >> conf_tmp && crontab conf_tmp && rm -f conf_tmp
            fi
		fi
		echo "全部配置完毕！可以通过tail -f /root/bin/deal_work_exec.log查看执行日志"
    elif [ "${mode}" = '2' ] ; then
        #判断有没有 当前脚本名_exec.sh 这个脚本(安装后实际执行的脚本名)
        if [ -f ~/bin/${shell_name}_exec.sh ] ; then 
            #删除文件
            rm ~/bin/${shell_name}_exec.sh
            #如果crontab只有该类任务,则清空crontab,否则只删除DEAL_WORK_GREP_TAG标识的行
            if [  `crontab -l |grep -v "DEAL_WORK_GREP_TAG" |wc -l` -eq 0 ] ; then 
                >conf_tmp && crontab conf_tmp && rm -f conf_tmp
            else
                crontab -l |grep -v "DEAL_WORK_GREP_TAG" > conf_tmp && crontab conf_tmp && rm -f conf_tmp
            fi
            echo "文件已删除，请手工核查!"
        else
            echo "未能找到${shell_name}_exec.sh文件，请核查！"
        fi
    else
        echo "不支持的模式！"
        exit
    fi
    exit #安装模式在安装完成后退出
fi

#你的CloudFlare注册账户邮箱
auth_email="REPLACE_STR_auth_email"
#你的CloudFlare账户Globel ID
auth_key="REPLACE_STR_auth_key"
#你的主域名
zone_name="REPLACE_STR_zone_name"
#你需要的完整的DDNS解析域名
record_name="REPLACE_STR_record_name"
#A或AAAA及ipv4或ipv6解析
record_type="REPLACE_STR_record_type"
#配置优先级
vps_flag="REPLACE_STR_vps_flag" #数值越小运行的优先级越高，例如优选机器配置110，后备机器配置120，在优选机器恢复后可以马上切换回优选机器。

######一键安装部分结束#####

#获取zone_id、record_id
zone_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" | grep -Po '(?<="id":")[^"]*' | head -1 )
record_identifier=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json"  | grep -Po '(?<="id":")[^"]*' | head -1 )
 

dns_flag=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json"  | grep -Po '(?<="ttl":)[^,]*' | head -1)
dns_ip=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records?name=$record_name" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json"  | grep -Po '(?<="content":")[^"]*' | head -1)
vps_ip=$(curl ifconfig.cc)



echo "$(date "+%Y-%m-%d %H:%M:%S")"
echo "本机IP地址: $vps_ip"
echo "当前在用地址: $dns_ip"
let vps_flagx=$vps_flag-50 
echo "本机服务等级: $vps_flag"
echo $vps_flagx
echo "当前在用等级: $dns_flag"

if [[ $(./nf) =~ "原生IP" ]]; then
    echo '本机可以解锁，检查dns服务的情况-->'
    if [[ $dns_flag -ge 100 ]] && [[ $vps_flag -ge $dns_flag ]]; then
        #statements
        echo "dns解析服务正常，服务级别不低于自己，无需处理，跳过."
    else
        echo "dns解析服务异常或者优先级低于自己，用自己替换."
        #更新DNS记录

        update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" --data "{\"type\":\"$record_type\",\"name\":\"$record_name\",\"content\":\"$vps_ip\",\"ttl\":$vps_flag,\"proxied\":false}")
        #反馈更新情况
        if [[ "$update" != "${update%success*}" ]] && [[ "$(echo $update | grep "\"success\":true")" != "" ]]; then
          echo "更新成功啦!"
          exit
        else
          echo "更新失败: $update"
          exit
        fi
    fi
else
    echo "本机无法Netflix解锁"
    if [[ $dns_ip == $vps_ip ]]; then
        echo "dns服务在用本机，标识无效"
        
        update=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone_identifier/dns_records/$record_identifier" -H "X-Auth-Email: $auth_email" -H "X-Auth-Key: $auth_key" -H "Content-Type: application/json" --data "{\"type\":\"$record_type\",\"name\":\"$record_name\",\"content\":\"$vps_ip\",\"ttl\":$vps_flagx,\"proxied\":false}")
        #反馈更新情况
        if [[ "$update" != "${update%success*}" ]] && [[ "$(echo $update | grep "\"success\":true")" != "" ]]; then
          echo "更新成功啦!"
          exit
        else
          echo "更新失败: $update"
          exit
        fi
    else
        echo "dns服务没有用本机，暂时跳过!"
    fi

fi
