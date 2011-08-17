From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: Linux vs FreeBSD Which is correct.
Date: Wed, 17 Aug 2011 13:20:34 -0400
Message-ID: <4E4BF862.3050205@earthlink.net>
References: <4E4BF456.9000807@earthlink.net> <CANh3MnZnyuvdiMyQTKKN=v-+y98FGbu+zA+=D4VnFL41AgRHpw@mail.gmail.com>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Emil S Tantilov <emils.tantilov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:33909
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751045Ab1HQRv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2011 13:51:26 -0400
In-Reply-To: <CANh3MnZnyuvdiMyQTKKN=v-+y98FGbu+zA+=D4VnFL41AgRHpw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2011 01:10 PM, Emil S Tantilov wrote:
> On Wed, Aug 17, 2011 at 10:03 AM, Stephen Clark<sclark46@earthlink.net>  wrote:
>    
>> Hello List,
>>
>> Firstly thank you for your patience.  I am replacing a bunch of FreeBSD
>> vpn/fw/routers
>> with a Linux based system.
>>
>> I have run into a situation where if I ping our HQ the response comes back
>> on a different
>> interface than what the request went out on. FreeBSD is happy and says it
>> got the response,
>> Linux is not and gives no indication it got a response.
>>      
> Try enabling ARP filtering:
> echo 1>  /proc/sys/net/ipv4/conf/all/arp_filter
Just tried it - made no difference.

Thanks.
[root@L101111 ~]# echo 1 > /proc/sys/net/ipv4/conf/all/arp_filterL101111:~
$ ping -I 172.21.76.150 172.21.232.55
PING 172.21.232.55 (172.21.232.55) from 172.21.76.150 : 56(84) bytes of 
data.
^C
--- 172.21.232.55 ping statistics ---
9 packets transmitted, 0 received, 100% packet loss, time 8238ms

L101111:~
$ sudo tcpdump -nli eth0 icmp
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
13:19:13.808262 IP 172.21.232.55 > 172.21.76.150: ICMP echo reply, id 
19545, seq 6, length 64
13:19:14.807541 IP 172.21.232.55 > 172.21.76.150: ICMP echo reply, id 
19545, seq 7, length 64
^C




