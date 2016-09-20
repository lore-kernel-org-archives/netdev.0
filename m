From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hns: mark symbols static where possible
Date: Mon, 19 Sep 2016 21:56:33 -0400 (EDT)
Message-ID: <20160919.215633.1223352245725461474.davem@davemloft.net>
References: <1474189645-6165-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        yankejian@huawei.com, huangdaode@hisilicon.com,
        lisheng011@huawei.com, fabf@skynet.be, xieqianqian@huawei.com,
        lipeng321@huawei.com, weiyongjun1@huawei.com, liguozhu@huawei.com,
        arnd@arndb.de, andrew@lunn.ch, chenny.xu@huawei.com,
        xypron.glpk@gmx.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474189645-6165-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Sun, 18 Sep 2016 17:07:25 +0800

> We get a few warnings when building kernel with W=1:
> drivers/net/ethernet/hisilicon/hisi_femac.c:943:5: warning: no previous prototype for 'hisi_femac_drv_suspend' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hisi_femac.c:960:5: warning: no previous prototype for 'hisi_femac_drv_resume' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:76:21: warning: no previous prototype for 'hns_ae_get_handle' [-Wmissing-prototypes]
> ....
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Does not apply cleanly to net-next, please respin.
