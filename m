From: Doug Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH v4 4/6] arm64: dts: rockchip: add the gmac power domain on rk3399
Date: Thu, 1 Sep 2016 14:57:58 -0700
Message-ID: <CAD=FV=Ww2eGyCbKAxFWNaMEzwwHEZJKvyeYpSGaX_2YqcLUM_w@mail.gmail.com>
References: <1472752204-8924-1-git-send-email-wxt@rock-chips.com> <1472752204-8924-5-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Derek Basehore <dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
        Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
        Huang Tao <huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Elaine Zhang <zhangqing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Jianqun Xu <jay.xu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Shunqian Zheng <zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel@list
To: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472752204-8924-5-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Sep 1, 2016 at 10:50 AM, Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org> wrote:
> This patch supports the gmac pd to save power consumption.
> Even though some boards not need Ethernet support, the driver
> core can also take care of powering up the pd before probe.
>
> Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> ---
>
> Changes in v4:
> - remove the Roger signed-off for domain patch.
>
> Changes in v3:
> - leave into two patches based on patchv2, and fix nits and commit, as
>   comment on https://patchwork.kernel.org/patch/9306339/
>
> Changes in v2:
> - Fixes the order, ss Heiko commnets on
>   https://patchwork.kernel.org/patch/9305991/
>
>  arch/arm64/boot/dts/rockchip/rk3399.dtsi | 10 ++++++++++
>  1 file changed, 10 insertions(+)

Reviewed-by: Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
