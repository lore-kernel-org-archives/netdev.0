From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: protocol for address routes
Date: Sat, 23 Aug 2008 05:17:12 -0700 (PDT)
Message-ID: <20080823.051712.47784171.davem@davemloft.net>
References: <20080819085441.7b0184d1@speedy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58185
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753003AbYHWMRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 08:17:13 -0400
In-Reply-To: <20080819085441.7b0184d1@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 19 Aug 2008 08:54:41 -0700

> This fixes a problem spotted with zebra, but not sure if it is
> necessary a kernel problem.  With IPV6 when an address is added to
> an interface, Zebra creates a duplicate RIB entry, one as a
> connected route, and other as a kernel route.
>
> When an address is added to an interface the RTN_NEWADDR message
> causes Zebra to create a connected route. In IPV4 when an address is
> added to an interface a RTN_NEWROUTE message is set to user space
> with the protocol RTPROT_KERNEL. Zebra ignores these messages,
> because it already has the connected route.
>
> The problem is that route created in IPV6 has route protocol ==
> RTPROT_BOOT.  Was this a design decision or a bug? This fixes
> it. Same patch applies to both net-2.6 and stable.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I've applied this to net-2.6, thanks Stephen.
