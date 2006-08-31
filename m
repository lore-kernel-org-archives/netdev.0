From: David Miller <davem@davemloft.net>
Subject: Re: SNMPv2 "ipFragFails" counter error
Date: Thu, 31 Aug 2006 15:25:04 -0700 (PDT)
Message-ID: <20060831.152504.44077733.davem@davemloft.net>
References: <1157121575.2540.9.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:8424
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932459AbWHaWY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 18:24:58 -0400
To: weid@nanjing-fnst.com
In-Reply-To: <1157121575.2540.9.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: weidong <weid@nanjing-fnst.com>
Date: Fri, 01 Sep 2006 10:39:35 -0400

> Hi, All
>   When I tested Linux kernel 2.6.17.7 about statistics
> "ipFragFails",found that this counter couldn't increase correctly. The
> criteria is RFC2011:
> RFC2011
>   ipFragFails OBJECT-TYPE
>     SYNTAX      Counter32
>     MAX-ACCESS  read-only
>     STATUS      current
>     DESCRIPTION
>             "The number of IP datagrams that have been discarded because
>             they needed to be fragmented at this entity but could not
>             be, e.g., because their Don't Fragment flag was set."
>     ::= { ip 18 }
> 
> When I send big IP packet to a router with DF bit set to 1 which need to
> be fragmented, and router just sends an ICMP error message
> ICMP_FRAG_NEEDED but no increments for this counter(in the function
> ip_fragment).
> 
> signed-off-by:Wei Dong <weid@nanjing-fnst.com>

Patch applied, thank you very much.
