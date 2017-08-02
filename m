From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH v2 05/11] net: stmmac: dwmac-rk: Add internal phy support
Date: Wed, 2 Aug 2017 11:46:57 +0800
Message-ID: <CAGb2v6766-8Cn0ZESo9Z0zU4yWR7Tt3+u0gdcd0LccYqLWW+3Q@mail.gmail.com>
References: <1501160156-30328-1-git-send-email-david.wu@rock-chips.com>
 <1501160540-30662-1-git-send-email-david.wu@rock-chips.com>
 <20170727134834.GD18666@lunn.ch> <65ae1747-4dff-b1d8-8aa3-684fc8c7809a@gmail.com>
 <69ad9443-ff65-8e49-df68-7e5e6c812d45@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Tao Huang <huangtao-TNX95d0MmH7DzftRWevZcw@public.gmane.org>, hwg-TNX95d0MmH7DzftRWevZcw@public.gmane.org,
        =?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
        Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Olof Johansson <olof-nZhT3qVonbNeoWH0uzbU5w@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        alex
To: "David.Wu" <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <69ad9443-ff65-8e49-df68-7e5e6c812d45-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David, Florian, Andrew

(resent in plain text)

On Fri, Jul 28, 2017 at 2:56 PM, David.Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org> wrote:
>
> Hi Florian,
>
> 在 2017/7/28 0:54, Florian Fainelli 写道:
>>
>> - if you need knowledge about this PHY connection type prior to binding
>> the PHY device and its driver (that is, before of_phy_connect()) we
>> could add a boolean property e.g: "phy-is-internal" that allows us to
>> know that, or we can have a new phy-mode value, e.g: "internal-rmii"
>> which describes that, either way would probably be fine, but the former
>> scales better
>>
>
> Using "phy-is-internal" is very helpful, but it is easy to confuse with
> the real internal PHY, may we use the other words like phy is inlined.

If "internal" is confusing, would "phy-is-integrated" in the MAC node work?

Either way we would like to have a definitive solution to this. Our
dwmac-sun8i driver is already in v4.13-rc1, with a somewhat flaky
method of knowing whether the internal PHY is used (phy-mode = "mii").

We really want a fix for this release, otherwise we would be force
to revert either the internal PHY part or the whole driver.

ChenYu

>
>> Then again, using phy-mode = "internal" even though this is Reduced MII
>> is not big of a deal IMHO as long as there is no loss of information and
>> that internal de-facto means internal reduced MII for instance.
>> --
>
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
