From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: Fix truncation of large IRQ numbers in
 phy_attached_print()
Date: Thu, 21 Sep 2017 17:40:14 +0200
Message-ID: <20170921154014.GI27589@lunn.ch>
References: <1505993222-16721-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Romain Perier <romain.perier@collabora.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1505993222-16721-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 21, 2017 at 01:27:02PM +0200, Geert Uytterhoeven wrote:
> Given NR_IRQS is 2048 on sparc64, and even 32784 on alpha, 3 digits is
> not enough to represent interrupt numbers on all architectures.  Hence
> PHY interrupt numbers may be truncated during printing.
> 
> Increase the buffer size from 4 to 8 bytes to fix this.
> 
> Fixes: 5e369aefdce4818c ("net: stmmac: Delete dead code for MDIO registration")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
