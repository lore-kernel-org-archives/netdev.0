From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4: unresolved multicast route cleanup
Date: Mon, 10 May 2010 04:48:00 -0700 (PDT)
Message-ID: <20100510.044800.163238362.davem@davemloft.net>
References: <4BE7CD4D.6050704@indakom.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andreas.meissner@indakom.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34335
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750970Ab0EJLrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 07:47:52 -0400
In-Reply-To: <4BE7CD4D.6050704@indakom.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Meissner <andreas.meissner@indakom.de>
Date: Mon, 10 May 2010 11:09:33 +0200

> from: Andreas Meissner <andreas.meissner@sphairon.com>
> 
> Fixes the expiration timer for unresolved multicast route entries.
> In case new multicast routing requests come in faster than the 
> expiration timeout occurs (e.g. zap through multicast TV streams), the 
> timer is prevented from being called at time for already existing entries.
> 
> Signed-off by: Andreas Meissner <andreas.meissner@sphairon.com>
> ---
> As the single timer is resetted to default whenever a new entry is made, 
> the timeout for existing unresolved entires are missed and/or not 
> updated. As a consequence new requests are denied when the limit of 
> unresolved entries has been reached because old entries live longer than 
> they are supposed to.
> The solution is to reset the timer only for the first unresolved entry 
> in the multicast routing cache. All other timers are already set and 
> updated correctly within the timer function itself by now.

Looks great, applied thanks!
