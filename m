From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ethernet: davinci_emac: Fix Unbalanced
 pm_runtime_enable
Date: Thu, 21 Apr 2016 14:58:06 -0400 (EDT)
Message-ID: <20160421.145806.264243075732892897.davem@davemloft.net>
References: <1461142573-4276-1-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, thomas.lendacky@amd.com, mugunthanvnm@ti.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	b.hutchman@gmail.com
To: narmstrong@baylibre.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461142573-4276-1-git-send-email-narmstrong@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Armstrong <narmstrong@baylibre.com>
Date: Wed, 20 Apr 2016 10:56:13 +0200

> In order to avoid an Unbalanced pm_runtime_enable in the DaVinci
> emac driver when the device is removed and re-probed, and a
> pm_runtime_disable() call in davinci_emac_remove().
> 
> Actually, using unbind/bind on a TI DM8168 SoC gives :
> $ echo 4a120000.ethernet > /sys/bus/platform/drivers/davinci_emac/unbind
> net eth1: DaVinci EMAC: davinci_emac_remove()
> $ echo 4a120000.ethernet > /sys/bus/platform/drivers/davinci_emac/bind
> davinci_emac 4a120000.ethernet: Unbalanced pm_runtime_enable
> 
> Cc: Brian Hutchinson <b.hutchman@gmail.com>
> Fixes: 3ba97381343b ("net: ethernet: davinci_emac: add pm_runtime support")
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>

Applied.
