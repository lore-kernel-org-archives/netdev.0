From: Pedro Ribeiro <pribeiro-bulk@net.ipl.pt>
Subject: Re[2]: [PATCH] Structure icmp6hdr (IPv6/ICMPv6) with bug in the bitfields!
Date: Tue, 14 Oct 2008 16:32:21 +0100
Message-ID: <13210415832.20081014163221@net.ipl.pt>
References: <159769323.20081014120620@net.ipl.pt> <87y70rxri6.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org,
	=?utf-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
To: arno@natisbad.org (Arnaud Ebalard)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out1.net.ipl.pt ([192.104.48.14]:55275 "EHLO
	smtp-out1.net.ipl.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbYJNPc1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 11:32:27 -0400
In-Reply-To: <87y70rxri6.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Arnaud,

Thanks for your quick answer ...

Here goes the information solicited.

TIA.

Tuesday, October 14, 2008, 1:58:41 PM, you wrote:

...

> can you confirm that you already activated CONFIG_IPV6_ROUTER_PREF in
> your kernel configuration?

host ~ # gzip -d -c /proc/config.gz | grep -F CONFIG_IPV6_ROUTER_PREF
CONFIG_IPV6_ROUTER_PREF=y

> What are the values of following parameters on your system?:

>   /proc/sys/net/ipv6/conf/*/accept_ra_rtr_pref
>   /proc/sys/net/ipv6/conf/*/accept_ra_pinfo
>   /proc/sys/net/ipv6/conf/*/accept_ra
>   /proc/sys/net/ipv6/conf/*/autoconf

All of them have value "1"

/proc/sys/net/ipv6/conf/all/accept_ra:1
/proc/sys/net/ipv6/conf/all/accept_ra_defrtr:1
/proc/sys/net/ipv6/conf/all/accept_ra_pinfo:1
/proc/sys/net/ipv6/conf/all/accept_ra_rtr_pref:1
/proc/sys/net/ipv6/conf/default/accept_ra:1
/proc/sys/net/ipv6/conf/default/accept_ra_defrtr:1
/proc/sys/net/ipv6/conf/default/accept_ra_pinfo:1
/proc/sys/net/ipv6/conf/default/accept_ra_rtr_pref:1
/proc/sys/net/ipv6/conf/eth0/accept_ra:1
/proc/sys/net/ipv6/conf/eth0/accept_ra_defrtr:1
/proc/sys/net/ipv6/conf/eth0/accept_ra_pinfo:1
/proc/sys/net/ipv6/conf/eth0/accept_ra_rtr_pref:1
/proc/sys/net/ipv6/conf/lo/accept_ra:1
/proc/sys/net/ipv6/conf/lo/accept_ra_defrtr:1
/proc/sys/net/ipv6/conf/lo/accept_ra_pinfo:1
/proc/sys/net/ipv6/conf/lo/accept_ra_rtr_pref:1
/proc/sys/net/ipv6/conf/all/autoconf:1
/proc/sys/net/ipv6/conf/default/autoconf:1
/proc/sys/net/ipv6/conf/eth0/autoconf:1
/proc/sys/net/ipv6/conf/lo/autoconf:1

Best regards.

-- 
Best regards,
 Pedro                            mailto:pribeiro-bulk@net.ipl.pt

