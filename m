From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: Fix CAN_(EFF|RTR)_FLAG handling in can_filter
Date: Wed, 03 Dec 2008 15:53:54 -0800 (PST)
Message-ID: <20081203.155354.206786507.davem@davemloft.net>
References: <20081128153317.GA3726@e-circ.dyndns.org>
	<49340DAE.5060603@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, kurt.van.dijck@eia.be, netdev@vger.kernel.org,
	stable@kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51147
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754355AbYLCXxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 18:53:54 -0500
In-Reply-To: <49340DAE.5060603@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Mon, 01 Dec 2008 17:15:42 +0100

> can: Fix CAN_(EFF|RTR)_FLAG handling in can_filter
> 
> Due to a wrong safety check in af_can.c it was not possible to filter
> for SFF frames with a specific CAN identifier without getting the
> same selected CAN identifier from a received EFF frame also.
> 
> This fix has a minimum (but user visible) impact on the CAN filter
> API and therefore the CAN version is set to a new date.
> 
> Indeed the 'old' API is still working as-is. But when now setting
> CAN_(EFF|RTR)_FLAG in can_filter.can_mask you might get less traffic
> than before - but still the stuff that you expected to get for your
> defined filter ...
> 
> Thanks to Kurt Van Dijck for pointing at this issue and for the review.
> 
> Signed-Off-by: Oliver Hartkopp <oliver@hartkopp.net>
> Acked-by: Kurt Van Dijck <kurt.van.dijck@eia.be>

Applied to net-2.6

But you are totally kidding yourself if you think that bumping
that completely stupid date string has any meaning at all for
userspace.

You're either keeping to the API you're exporting to userspace
or you're not.  And using a date string which userland has to
test is just a cop-out for not breaking userspace interfaces.
