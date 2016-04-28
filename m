From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: davinci_emac: Fix devioctl while in
 fixed link
Date: Thu, 28 Apr 2016 15:52:07 -0400 (EDT)
Message-ID: <20160428.155207.1419062437411480208.davem@davemloft.net>
References: <1461606098-20057-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, thomas.lendacky@amd.com, mugunthanvnm@ti.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	b.hutchman@gmail.com
To: narmstrong@baylibre.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461606098-20057-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Armstrong <narmstrong@baylibre.com>
Date: Mon, 25 Apr 2016 19:41:38 +0200

> When configured in fixed link, the DaVinci emac driver sets the
> priv->phydev to NULL and further ioctl calls to the phy_mii_ioctl()
> causes the kernel to crash.
> 
> Cc: Brian Hutchinson <b.hutchman@gmail.com>
> Fixes: 1bb6aa56bb38 ("net: davinci_emac: Add support for fixed-link PHY")
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Applied, thanks Neil.
