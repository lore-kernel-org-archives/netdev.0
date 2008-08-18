From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6:fix the return interface index when get it while
 no message is received
Date: Sun, 17 Aug 2008 23:22:02 -0700 (PDT)
Message-ID: <20080817.232202.06571162.davem@davemloft.net>
References: <48A911AD.7060102@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: yanghy@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36087
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750885AbYHRGWC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Aug 2008 02:22:02 -0400
In-Reply-To: <48A911AD.7060102@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Hongyang <yanghy@cn.fujitsu.com>
Date: Mon, 18 Aug 2008 14:07:41 +0800

> When get receiving interface index while no message is received,
> the bounded device's index of the socket should be returned.
> 
> RFC 3542:
>    Issuing getsockopt() for the above options will return the sticky
>    option value i.e., the value set with setsockopt().  If no sticky
>    option value has been set getsockopt() will return the following
>    values:
> 
>    -  For the IPV6_PKTINFO option, it will return an in6_pktinfo
>       structure with ipi6_addr being in6addr_any and ipi6_ifindex being
>       zero.
> 
> 
> Signed-off-by: Yang Hongyang<yanghy@cn.fujitsu.com>

Applied, thanks Yang.
