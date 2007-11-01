From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: docbook fixes for netif_ functions
Date: Thu, 01 Nov 2007 02:22:09 -0700 (PDT)
Message-ID: <20071101.022209.141061101.davem@davemloft.net>
References: <20071031140848.4a425df2@freepuppy.rosehill>
	<20071031153620.01cf5eeb.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: rdunlap@xenotime.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56382
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750812AbXKAJWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 05:22:09 -0400
In-Reply-To: <20071031153620.01cf5eeb.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Wed, 31 Oct 2007 15:36:20 -0700

> > + *	return values (usually ignored).
> > + *	NET_RX_SUCCESS	(no congestion)
> > + *	NET_RX_DROP     (packet was dropped)
> 
> For the 3 lines above, how about:
> 
>  *	Return values (usually ignored):
>  *	NET_RX_SUCCESS: no congestion
>  *	NET_RX_DROP: packet was dropped
> 
> 
> only because they come out of kernel-doc badly, munged together like so:
> 
>        return  values  (usually  ignored).    NET_RX_SUCCESS (no   congestion)
>        NET_RX_DROP     (packet was dropped)

I've applied Stephen's patch with this minor correction
added.
