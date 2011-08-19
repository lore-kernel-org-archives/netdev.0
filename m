From: Dmitry Butskoy <buc@odusz.so-cdu.ru>
Subject: Traceroute and "ping" sockets: some questions
Date: Fri, 19 Aug 2011 15:19:16 +0400
Message-ID: <4E4E46B4.9010909@odu.neva.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.odu.neva.ru ([194.85.100.6]:51245 "EHLO mail2.odu.neva.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000Ab1HSLY0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 07:24:26 -0400
Received: from buc.odu.neva.ru (buc.odu.neva.ru [194.85.100.33])
	by mail2.odu.neva.ru (Postfix) with ESMTPA id E70DC14A82B1
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 15:19:16 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I've released new version of the Linux traceroute 2.0.18, which supports 
new (SOCK_DGRAM, IPPROTO_ICMP) sockets, appeared in the kernel 3.0 . 
This way users might perform icmp tracerouting (`-I') without setuid bit 
or cap_net_raw settings of the executable.
(See it at 
http://sourceforge.net/projects/traceroute/files/traceroute/traceroute-2.0.18/)

I would like to ask some questions:

- Currently such "ping" sockets implemented for IPv4 only. Are there any 
plans to implement it for IPv6 as well?

The traceroute-2.0.18 is ready for IPv6 anyway -- just wait for 
appearing it in the kernel without recompile (I hope :) ) -- but I would 
prefer to test it as soon as possible.

- Are there any plans to implement some "rate control" (maybe 
sysctl-configurable too), to restrict unprivileged users to send icmp 
echoes too fast (ie. faster than 200 ms -- the current ping(8) restriction)?


Regards,
Dmitry Butskoy
http://www.fedoraproject.org/wiki/DmitryButskoy
