From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v3] net: hns: mark symbols static where possible
Date: Tue, 04 Oct 2016 09:42:24 +0200
Message-ID: <44733796.adHYRchuZI@wuerfel>
References: <1475309726-21334-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        davem@davemloft.net, yankejian@huawei.com,
        huangdaode@hisilicon.com, lisheng011@huawei.com,
        xieqianqian@huawei.com, fabf@skynet.be, lipeng321@huawei.com,
        colin.king@canonical.com, simon.horman@netronome.com,
        andrew@lunn.ch, ivecera@redhat.com, chenny.xu@huawei.com,
        xypron.glpk@gmx.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, xie.baoyou@zte.com.cn,
        han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1475309726-21334-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, October 1, 2016 4:15:26 PM CEST Baoyou Xie wrote:
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
> ....
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> So this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> ---
>  drivers/net/ethernet/hisilicon/hip04_eth.c         |  2 +-
>  drivers/net/ethernet/hisilicon/hisi_femac.c        |  6 ++---

These two changes have already gone in as separate patches that
you have sent earlier.

Baoyou, please stop sending patches for now until you have had
a chance to discuss your workflow with me.

You are doing something really wrong here and we need to figure
out what is causing this so you don't cause maintainers extra
work.

	Arnd
