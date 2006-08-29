From: David Miller <davem@davemloft.net>
Subject: Re: SNMPv2 "ipv6IfStatsInAddrErrors" counter error
Date: Tue, 29 Aug 2006 00:01:29 -0700 (PDT)
Message-ID: <20060829.000129.112621264.davem@davemloft.net>
References: <1119213904.2569.23.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:54757
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932140AbWH2HBc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 03:01:32 -0400
To: lvly@nanjing-fnst.com
In-Reply-To: <1119213904.2569.23.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lv Liangying <lvly@nanjing-fnst.com>
Date: Sun, 19 Jun 2005 16:45:04 -0400

> Hi, All
> 
>    When I tested Linux kernel 2.6.17.7 about statistics
> "ipv6IfStatsInAddrErrors", found that this counter couldn't increase
> correctly. The criteria is RFC2465:
>  ipv6IfStatsInAddrErrors OBJECT-TYPE
>       SYNTAX      Counter32
>       MAX-ACCESS  read-only
>       STATUS      current
>       DESCRIPTION
>          "The number of input datagrams discarded because
>          the IPv6 address in their IPv6 header's destination
>          field was not a valid address to be received at
>          this entity.  This count includes invalid
>          addresses (e.g., ::0) and unsupported addresses
>          (e.g., addresses with unallocated prefixes).  For
>          entities which are not IPv6 routers and therefore
>          do not forward datagrams, this counter includes
>          datagrams discarded because the destination address
>          was not a local address."
>       ::= { ipv6IfStatsEntry 5 }
> 
> When I send packet to host with destination that is ether invalid
> address(::0) or unsupported addresses(1::1), the Linux kernel just
> discard the packet, and the counter doesn't increase(in the function
> ip6_pkt_discard).
> 
> signed-off by Lv Liangying <lvly@nanjing-fnst.com>

Looks good, patch applied.  Thanks a lot.

BTW, the correct form of a sign off is:

Signed-off-by: David S. Miller <davem@davemloft.net>

Please keep the capitalization, colon character, etc.
consistent with that.  Thanks again.
