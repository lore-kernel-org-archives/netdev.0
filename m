From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hisilicon: mark symbols static where possible
Date: Mon, 26 Sep 2016 02:24:43 -0400 (EDT)
Message-ID: <20160926.022443.2147767413776159997.davem@davemloft.net>
References: <1474795004-8743-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, xie.baoyou@zte.com.cn, han.fei@zte.com.cn,
        tang.qiang007@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474795004-8743-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sun, 25 Sep 2016 17:16:44 +0800

> We get 2 warnings when building kernel with W=1:
> drivers/net/ethernet/hisilicon/hisi_femac.c:943:5: warning: no previous prototype for 'hisi_femac_drv_suspend' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hisi_femac.c:960:5: warning: no previous prototype for 'hisi_femac_drv_resume' [-Wmissing-prototypes]
> 
> In fact, these two functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
