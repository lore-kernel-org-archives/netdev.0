From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] icmp: Account for ICMP out errors
Date: Sat, 03 Apr 2010 15:09:24 -0700 (PDT)
Message-ID: <20100403.150924.192361698.davem@davemloft.net>
References: <1269641190.2256.1.camel@edumazet-laptop>
	<1269643575.2256.19.camel@edumazet-laptop>
	<1270192174.1936.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60764
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752917Ab0DCWJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 18:09:22 -0400
In-Reply-To: <1270192174.1936.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 02 Apr 2010 09:09:34 +0200

> [PATCH net-next-2.6] icmp: Account for ICMP out errors
> 
> When ip_append() fails because of socket limit or memory shortage,
> increment ICMP_MIB_OUTERRORS counter, so that "netstat -s" can report
> these errors.
> 
> LANG=C netstat -s | grep "ICMP messages failed"
>     0 ICMP messages failed
> 
> For IPV6, implement ICMP6_MIB_OUTERRORS counter as well.
> 
> # grep Icmp6OutErrors /proc/net/dev_snmp6/*
> /proc/net/dev_snmp6/eth0:Icmp6OutErrors                   	0
> /proc/net/dev_snmp6/lo:Icmp6OutErrors                   	0
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
