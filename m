From: David Miller <davem@davemloft.net>
Subject: Re: inet: Remove bogus IGMPv3 report handling
Date: Fri, 12 Feb 2010 11:42:56 -0800 (PST)
Message-ID: <20100212.114256.226910552.davem@davemloft.net>
References: <20100208032630.GA4369@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42223
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756865Ab0BLTml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 14:42:41 -0500
In-Reply-To: <20100208032630.GA4369@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 8 Feb 2010 14:26:30 +1100

> inet: Remove bogus IGMPv3 report handling
> 
> Currently we treat IGMPv3 reports as if it were an IGMPv2/v1 report.
> This is broken as IGMPv3 reports are formatted differently.  So we
> end up suppressing a bogus multicast group (which should be harmless
> as long as the leading reserved field is zero).
> 
> In fact, IGMPv3 does not allow membership report suppression so
> we should simply ignore IGMPv3 membership reports as a host.
> 
> This patch does exactly that.  I kept the case statement for it
> so people won't accidentally add it back thinking that we overlooked
> this case.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6 and queued up for -stable, thanks!
