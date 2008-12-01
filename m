From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] can: Fix CAN_(EFF|RTR)_FLAG handling in can_filter
Date: Mon, 1 Dec 2008 18:52:25 +0100
Message-ID: <20081201175225.GA1835@uranus.ravnborg.org>
References: <20081128153317.GA3726@e-circ.dyndns.org> <49340DAE.5060603@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Greg KH <greg@kroah.com>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Linux Netdev List <netdev@vger.kernel.org>, stable@kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:59442 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbYLARzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 12:55:40 -0500
Content-Disposition: inline
In-Reply-To: <49340DAE.5060603@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 01, 2008 at 05:15:42PM +0100, Oliver Hartkopp wrote:
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

If Kurt tested this patch then he should
be credited with a "Tested-by:" tag.

I recall he did but I deleted the thread from my can mailbox.

	Sam
