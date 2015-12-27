From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH 06/10] net: hns: use to_platform_device()
Date: Sun, 27 Dec 2015 15:23:30 +0200
Message-ID: <CAHp75Vcsa=yWPXA6y27e1q2D37XVPd_87nYCdHNkkppv=3Ptgw@mail.gmail.com>
References: <a554e6af3a3528c2206c94dab62b7800f96caa4b.1451221174.git.geliangtang@163.com>
	<0801535a0c35424d2fd2e91f6ed58058d884e147.1451221174.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Yisen Zhuang <yisen.zhuang@huawei.com>,
	yankejian <yankejian@huawei.com>,
	huangdaode <huangdaode@hisilicon.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Geliang Tang <geliangtang@163.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0801535a0c35424d2fd2e91f6ed58058d884e147.1451221174.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Dec 27, 2015 at 3:15 PM, Geliang Tang <geliangtang@163.com> wrote:
> Use to_platform_device() instead of open-coding it.
>
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> index 8c30cec..d2263c7 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> @@ -499,8 +499,7 @@ void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
>         int base_irq_idx = hns_rcb_get_base_irq_idx(rcb_common);
>         struct device_node *np = rcb_common->dsaf_dev->dev->of_node;
>         struct platform_device *pdev =
> -               container_of(rcb_common->dsaf_dev->dev,
> -                            struct platform_device, dev);
> +               to_platform_device(rcb_common->dsaf_dev->dev);

Can it be one line after all? Please, check this for all your patches
of such kind.

>         bool is_ver1 = AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver);
>
>         for (i = 0; i < ring_num; i++) {
> --
> 2.5.0
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
With Best Regards,
Andy Shevchenko
