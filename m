From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy: mark lan88xx_suspend() static
Date: Mon, 19 Sep 2016 21:55:51 -0400 (EDT)
Message-ID: <20160919.215551.2302635477525145919.davem@davemloft.net>
References: <1474187194-21322-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474187194-21322-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sun, 18 Sep 2016 16:26:34 +0800

> We get 1 warning when building kernel with W=1:
> drivers/net/phy/microchip.c:58:5: warning: no previous prototype for 'lan88xx_suspend' [-Wmissing-prototypes]
> 
> In fact, this function is only used in the file in which it is
> declared and don't need a declaration, but can be made static.
> so this patch marks this function with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
