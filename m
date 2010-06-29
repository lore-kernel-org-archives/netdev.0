From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next-2.6] snmp: 64bit ipstats_mib for all arches
Date: Wed, 30 Jun 2010 00:07:14 +0900
Message-ID: <4C2A0C22.4010202@linux-ipv6.org>
References: <1277398051.2816.644.camel@edumazet-laptop> <1277819286.3531.555.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:32776 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755236Ab0F2PHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 11:07:17 -0400
In-Reply-To: <1277819286.3531.555.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Thank you for doing this work!

Eric Dumazet wrote:
> /proc/net/snmp and /proc/net/netstat expose SNMP counters.
> 
> Width of these counters is either 32 or 64 bits, depending on the size
> of "unsigned long" in kernel.
> 
> This means user program parsing these files must already be prepared to
> deal with 64bit values, regardless of user program being 32 or 64 bit.

Well, I'm rather not in favor of breaking user-space apps.
How about leaving legacy procfs as-is and fix netlink-side only?

--yoshfuji
