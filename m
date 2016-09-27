From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: hns: mark symbols static where possible
Date: Tue, 27 Sep 2016 07:50:14 -0400 (EDT)
Message-ID: <20160927.075014.320869544955826394.davem@davemloft.net>
References: <1474881218-21219-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, yankejian@huawei.com,
        huangdaode@hisilicon.com, lisheng011@huawei.com,
        lipeng321@huawei.com, xieqianqian@huawei.com, fabf@skynet.be,
        colin.king@canonical.com, geliangtang@163.com, arnd@arndb.de,
        andrew@lunn.ch, chenny.xu@huawei.com, xypron.glpk@gmx.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        xie.baoyou@zte.com.cn, han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46262 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932240AbcI0Lu0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 07:50:26 -0400
In-Reply-To: <1474881218-21219-1-git-send-email-baoyou.xie@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Mon, 26 Sep 2016 17:13:38 +0800

> We get a few warnings when building kernel with W=1:
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:76:21: warning: no previous prototype for 'hns_ae_get_handle' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:274:6: warning: no previous prototype for 'hns_ae_stop' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:302:6: warning: no previous prototype for 'hns_ae_toggle_ring_irq' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:490:6: warning: no previous prototype for 'hns_ae_update_stats' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:573:6: warning: no previous prototype for 'hns_ae_get_stats' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:605:6: warning: no previous prototype for 'hns_ae_get_strings' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:638:5: warning: no previous prototype for 'hns_ae_get_sset_count' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:687:6: warning: no previous prototype for 'hns_ae_update_led_status' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:698:5: warning: no previous prototype for 'hns_ae_cpld_set_led_id' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:710:6: warning: no previous prototype for 'hns_ae_get_regs' [-Wmissing-prototypes]
> drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c:735:5: warning: no previous prototype for 'hns_ae_get_regs_len' [-Wmissing-prototypes]
> ....
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

This still doesn't apply to the net-next tree.

If you aren't actually building your patch against the net-next
tree, don't bother submitting these patches any more.
