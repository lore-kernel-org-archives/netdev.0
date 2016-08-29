From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net v2 8/9] net: ethernet: mediatek: use
 devm_mdiobus_alloc instead of mdiobus_alloc inside mtk_mdio_init
Date: Mon, 29 Aug 2016 15:06:28 +0200
Message-ID: <20160829130628.GD12465@lunn.ch>
References: <1472447003-30726-1-git-send-email-sean.wang@mediatek.com>
 <1472447003-30726-9-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: john@phrozen.org, davem@davemloft.net, nbd@openwrt.org,
        netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com
To: sean.wang@mediatek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46753 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756604AbcH2NGj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 09:06:39 -0400
Content-Disposition: inline
In-Reply-To: <1472447003-30726-9-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 29, 2016 at 01:03:22PM +0800, sean.wang@mediatek.com wrote:
> From: Sean Wang <sean.wang@mediatek.com>
> 
> a lot of parts in the driver uses devm_* APIs to gain benefits from the
> device resource management, so devm_mdiobus_alloc is also used instead
> of mdiobus_alloc to have more elegant code flow.
> 
> Using common code provided by the devm_* helps to
> 1) have simplified the code flow as [1] says
> 2) decrease the risk of incorrect error handling by human
> 3) only a few drivers used it since it ware proposed on linux 3.16,
> so just hope to promote for this.
> 
> Signed-off-by: Sean Wang <sean.wang@mediatek.com>
> 
> ---
> ref.
> [1] https://patchwork.ozlabs.org/patch/344093/
> ---

Hi Sean

Your footnote is below the ---, so won't make it into the change log. 

Apart from that,

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
