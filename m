From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net] net: dsa: skb_put_padto() already frees nskb
Date: Mon, 21 Aug 2017 21:47:24 +0200
Message-ID: <20170821194724.GC7076@lunn.ch>
References: <20170821194143.27885-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        vivien.didelot@savoirfairelinux.com, woojung.huh@microchip.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37642 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753644AbdHUTr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 15:47:29 -0400
Content-Disposition: inline
In-Reply-To: <20170821194143.27885-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 21, 2017 at 12:41:43PM -0700, Florian Fainelli wrote:
> skb_put_padto() already frees the passed sk_buff reference upon error,
> so calling kfree_skb() on it again is not necessary.
> 
> Detected by CoverityScan, CID#1416687 ("USE_AFTER_FREE")
> 
> Fixes: e71cb9e00922 ("net: dsa: ksz: fix skb freeing")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
