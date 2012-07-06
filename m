From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: Re: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Fri, 06 Jul 2012 11:47:37 +0200
Message-ID: <2d2806e8e8ecad5646524acf2c4c5bcf@justnet.pl>
Reply-To: <adam.niescierowicz@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:45345 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750808Ab2GFJrr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2012 05:47:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
Can I send something that will help determine the cause of the problem?


W dniu 08.06.2012 11:41, Eric Dumazet napisa=C5=82(a):

> On Fri, 2012-06-08 at 10:58 +0200, Nie=C5=9Bcierowicz Adam wrote:
>
>> Hello, recently we changed on the router kernel from 2.6.38.1 to=20
>> 3.4.1
>> and noticed 30% packet loss when traffic increases up to 250MB / s.
>> Similar is for kernel 3.5-rc1 Here a link to ifstat
>> http://wklej.org/id/767577/ [2]
>
> You should give as much as possible delails on your setup (hardware,
> software)
>
> lspci
> cat /proc/cpuinfo
> cat /proc/interrupts
> ifconfig -a
> tc -s -d qdisc
> dmesg
> netstat -s

currently running on 2.6.38.1 and traffic is 100Mb / s

lspci: http://wklej.org/id/769102/
/proc/cpuinfo: http://wklej.org/id/769104/
/proc/interrupts: http://wklej.org/id/769106/
ifconfig -a: http://wklej.org/id/769108/
tc -s -d qdisc: http://wklej.org/id/769109/
dmesg: here are some logs from iptables
netstat -s: http://wklej.org/id/769110/
lsmod: http://wklej.org/id/769117/
/proc/net/softnet_stat: http://wklej.org/id/769116/
