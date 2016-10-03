From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: mediatek: mark symbols static where
 possible
Date: Mon, 03 Oct 2016 01:24:26 -0400 (EDT)
Message-ID: <20161003.012426.1613500726219944583.davem@davemloft.net>
References: <1475221730-18773-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nbd@openwrt.org, blogic@openwrt.org, matthias.bgg@gmail.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, xie.baoyou@zte.com.cn, han.fei@zte.com.cn,
        tang.qiang007@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750989AbcJCFYd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 01:24:33 -0400
In-Reply-To: <1475221730-18773-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Fri, 30 Sep 2016 15:48:50 +0800

> We get 2 warnings when building kernel with W=1:
> drivers/net/ethernet/mediatek/mtk_eth_soc.c:2041:5: warning: no previous prototype for 'mtk_get_link_ksettings' [-Wmissing-prototypes]
> drivers/net/ethernet/mediatek/mtk_eth_soc.c:2052:5: warning: no previous prototype for 'mtk_set_link_ksettings' [-Wmissing-prototypes]
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> So this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied, thanks.
