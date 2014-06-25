From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: allwinner: emac: Add missing free_irq
Date: Wed, 25 Jun 2014 16:32:00 -0700 (PDT)
Message-ID: <20140625.163200.509097762043557956.davem@davemloft.net>
References: <1403556580-21818-1-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
To: maxime.ripard@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403556580-21818-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard@free-electrons.com>
Date: Mon, 23 Jun 2014 22:49:40 +0200

> If the mdio probe function fails in emac_open, the interrupt we just requested
> isn't freed. If emac_open is called again, for example because we try to set up
> the interface again, the kernel will oops because the interrupt wasn't properly
> released.
> 
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
> Cc: <stable@vger.kernel.org> # 3.11+

Applied, thank you.
