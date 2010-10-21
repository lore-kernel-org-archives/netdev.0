From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: generate random MAC address once, not every
 ifup
Date: Thu, 21 Oct 2010 03:17:13 -0700 (PDT)
Message-ID: <20101021.031713.229751156.davem@davemloft.net>
References: <20101018231639.GA15955@mersenne.largestprime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org
To: bernard@largestprime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43804
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756426Ab0JUKQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:16:50 -0400
In-Reply-To: <20101018231639.GA15955@mersenne.largestprime.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernard Blackham <bernard@largestprime.net>
Date: Tue, 19 Oct 2010 10:16:39 +1100

> The smsc95xx driver currently generates a new random MAC address
> every time the interface is brought up. This makes it impossible to
> override using the standard `ifconfig hw ether` approach.
> 
> Past patches tried to make the MAC address a module parameter or
> base it off the die ID, but it seems to me much simpler (and
> hopefully less controversial) to stick with the current random
> generation scheme, but allow the user to change the address.
> 
> This patch does exactly that - it moves the random address
> generation from smsc95xx_reset() into smsc95xx_bind(), so that it is
> done once on module load, not on every ifup. The user can then
> override this using the standard mechanisms.
> 
> Applies against 2.6.35 and linux-2.6 head.
> 
> Signed-off-by: Bernard Blackham <b-omap@largestprime.net>

Applied.
