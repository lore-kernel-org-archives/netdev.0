From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: arc_emac: mark arc_mdio_reset() static
Date: Tue, 06 Sep 2016 15:59:54 -0700 (PDT)
Message-ID: <20160906.155954.402912436042138430.davem@davemloft.net>
References: <1473150116-26226-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wxt@rock-chips.com, heiko@sntech.de, marex@denx.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473150116-26226-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Tue,  6 Sep 2016 16:21:56 +0800

> We get 1 warning when building kernel with W=1:
> drivers/net/ethernet/arc/emac_mdio.c:107:5: warning: no previous prototype for 'arc_mdio_reset' [-Wmissing-prototypes]
> 
> In fact, this function is only used in the file in which it is
> declared and don't need a declaration, but can be made static.
> so this patch marks this function with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
