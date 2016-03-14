From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: mediatek: remove incorrect dma_mask assignment
Date: Mon, 14 Mar 2016 13:06:39 -0400 (EDT)
Message-ID: <20160314.130639.328854823799037233.davem@davemloft.net>
References: <1457964435-2945038-1-git-send-email-arnd@arndb.de>
	<1457964435-2945038-2-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, blogic@openwrt.org, matthias.bgg@gmail.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457964435-2945038-2-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 14 Mar 2016 15:07:11 +0100

> Device drivers should not mess with the DMA mask directly,
> but instead call dma_set_mask() etc if needed.
> 
> In case of the mtk_eth_soc driver, the mask already gets set
> correctly when the device is created, and setting it again
> is against the documented API.
> 
> This removes the incorrect setting.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
