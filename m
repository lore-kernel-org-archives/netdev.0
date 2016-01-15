From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 next-next] net: hns: enet specifies a reference to dsaf
Date: Thu, 14 Jan 2016 20:28:00 -0600
Message-ID: <20160115022800.GA29856@rob-hp-laptop>
References: <1452654880-28980-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	catalin.marinas-5wv7dgnIgG8@public.gmane.org, will.deacon-5wv7dgnIgG8@public.gmane.org,
	huangdaode-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, liguozhu-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org,
	fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	andriy.shevchenko-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Kejian Yan <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1452654880-28980-1-git-send-email-yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 13, 2016 at 11:14:40AM +0800, Kejian Yan wrote:
> This patch replace the assoication between dsaf and enet from string
> matching to object reference. It requires the DTS to be updated within
> BIOS. Thanks god it can be done for all released boards.
> 
> Signed-off-by: Kejian Yan <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
> change log:
> v2:
>  merge the two patches into one to allow bisection.


> 
> v1:
>  first submit.
> 
> v1 patch reference:
>  https://lkml.org/lkml/2015/12/5/11
>  https://lkml.org/lkml/2015/12/5/12
> ---
>  .../devicetree/bindings/net/hisilicon-hns-dsaf.txt    |  5 +----
>  .../devicetree/bindings/net/hisilicon-hns-nic.txt     |  7 ++++---
>  arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi          | 19 +++++++++----------

Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

>  drivers/net/ethernet/hisilicon/hns/hnae.c             | 17 +++++++----------
>  drivers/net/ethernet/hisilicon/hns/hnae.h             |  7 +++++--
>  drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c     |  4 ++++
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c    | 10 +---------
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h    |  1 +
>  drivers/net/ethernet/hisilicon/hns/hns_enet.c         | 13 +++++++++----
>  drivers/net/ethernet/hisilicon/hns/hns_enet.h         |  2 +-
>  10 files changed, 42 insertions(+), 43 deletions(-)

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
