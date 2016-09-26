From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: bcmgenet: remove unused function in bcmgenet.c
Date: Mon, 26 Sep 2016 02:24:49 -0400 (EDT)
Message-ID: <20160926.022449.1500775270978919331.davem@davemloft.net>
References: <1474784595-29779-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474784595-29779-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sun, 25 Sep 2016 14:23:15 +0800

> We get 1 warning when building kernel with W=1:
> drivers/net/ethernet/broadcom/genet/bcmgenet.c:2763:5: warning: no previous prototype for 'bcmgenet_hfb_add_filter' [-Wmissing-prototypes]
> 
> In fact, this function is implemented in
> drivers/net/ethernet/broadcom/genet/bcmgenet.c, but be called
> by no one, thus can be removed.
> 
> So this patch removes the unused functions.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
