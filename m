From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: mediatek: check device_reset return code
Date: Mon, 14 Mar 2016 13:06:45 -0400 (EDT)
Message-ID: <20160314.130645.572195280477206552.davem@davemloft.net>
References: <1457964435-2945038-1-git-send-email-arnd@arndb.de>
	<1457964435-2945038-3-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, blogic@openwrt.org, matthias.bgg@gmail.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457964435-2945038-3-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 14 Mar 2016 15:07:12 +0100

> The device_reset() function may fail, so we have to check
> its return value, e.g. to make deferred probing work correctly.
> gcc warns about it because of the warn_unused_result attribute:
> 
> drivers/net/ethernet/mediatek/mtk_eth_soc.c: In function 'mtk_probe':
> drivers/net/ethernet/mediatek/mtk_eth_soc.c:1679:2: error: ignoring return value of 'device_reset', declared with attribute warn_unused_result [-Werror=unused-result]
> 
> This adds the trivial error check to propagate the return value
> to the generic platform device probe code.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
