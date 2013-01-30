From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [RFC 1/3] net: freescale: fec: add support for optional enet_out
 clk
Date: Wed, 30 Jan 2013 13:25:50 +0800
Message-ID: <20130130052547.GA23670@S2100-06.ap.freescale.net>
References: <1359470773-14290-1-git-send-email-w.sang@pengutronix.de>
 <1359470773-14290-2-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Shawn Guo <shawn.guo@freescale.com>
To: Wolfram Sang <w.sang@pengutronix.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe004.messaging.microsoft.com ([213.199.154.142]:3095
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753379Ab3A3E45 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 23:56:57 -0500
Content-Disposition: inline
In-Reply-To: <1359470773-14290-2-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for working on this, Wolfram.

On Tue, Jan 29, 2013 at 03:46:11PM +0100, Wolfram Sang wrote:
> Some MX28 boards need the internal enet_out clock to be enabled. So, do
> this in the driver iff the clock was referenced via devicetree.
> 
> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>

Acked-by: Shawn Guo <shawn.guo@linaro.org>

> ---
> 
> davidm: Please don't apply before Shawn as the mxs-maintainer has given his ack
> on the general procedure. Or maybe he can merge it via his tree?
> 
I prefer to have the patch go via net tree for 3.9, and then we clean
up mxs platform code from 3.9-rc1.

Shawn
