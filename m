From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH 1/5] net: ep93xx_eth: pass struct device to DMA API
	functions
Date: Thu, 2 Jun 2011 10:52:24 +0100
Message-ID: <20110602095224.GT3660@n2100.arm.linux.org.uk>
References: <89df467f9811b4f869513de3ada90ce7de74c6d1.1307006502.git.mika.westerberg@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hsweeten@visionengravers.com,
	ryan@bluewatersys.com, kernel@wantstofly.org,
	linux-arm-kernel@lists.infradead.org
To: Mika Westerberg <mika.westerberg@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:41177 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933276Ab1FBJwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 05:52:39 -0400
Content-Disposition: inline
In-Reply-To: <89df467f9811b4f869513de3ada90ce7de74c6d1.1307006502.git.mika.westerberg@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 02, 2011 at 12:38:13PM +0300, Mika Westerberg wrote:
> We shouldn't use NULL for any DMA API functions, unless we are dealing with
> ISA or EISA device. So pass correct struct dev pointer to these functions.

Thanks for doing this - it certainly makes things more correct, even
if the original problem has been resolved by the troublesome GFP_DMA
commit having been reverted.  As such I think this patch series should
still be applied.

I think the series should be re-ordered so that patch 5 is first however,
as you can do that with or without the remainder of the patches.

For the entire series:

Acked-by: Russell King <rmk+kernel@arm.linux.org.uk>
