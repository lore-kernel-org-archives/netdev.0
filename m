From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Fix truncation of large IRQ numbers in
 phy_attached_print()
Date: Thu, 21 Sep 2017 20:36:19 -0700 (PDT)
Message-ID: <20170921.203619.1150984231295351664.davem@davemloft.net>
References: <1505993222-16721-1-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, romain.perier@collabora.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert+renesas@glider.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1505993222-16721-1-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert+renesas@glider.be>
Date: Thu, 21 Sep 2017 13:27:02 +0200

> Given NR_IRQS is 2048 on sparc64, and even 32784 on alpha, 3 digits is
> not enough to represent interrupt numbers on all architectures.  Hence
> PHY interrupt numbers may be truncated during printing.
> 
> Increase the buffer size from 4 to 8 bytes to fix this.
> 
> Fixes: 5e369aefdce4818c ("net: stmmac: Delete dead code for MDIO registration")
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>

Applied.
