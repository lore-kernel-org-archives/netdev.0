From: Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>
Subject: Re: [PATCH 2/3] ARM: sunxi: h3/h5: Add sun8i-h3-ephy compatible
Date: Fri, 28 Jul 2017 17:46:48 +0800
Message-ID: <700AE117-FE97-4240-830B-256E922D654D@aosc.io>
References: <20170728092818.23419-1-clabbe.montjoie@gmail.com> <20170728092818.23419-3-clabbe.montjoie@gmail.com> <CAGb2v67Lt5whR4=6+SDc=Ooi6zyiHuprW+7zbPh0njnKOCiFFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
        Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGb2v67Lt5whR4=6+SDc=Ooi6zyiHuprW+7zbPh0njnKOCiFFA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



于 2017年7月28日 GMT+08:00 下午5:44:51, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org> 写到:
>On Fri, Jul 28, 2017 at 5:28 PM, Corentin Labbe
><clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> This patch adds the sun8i-h3-ephy compatible to the internal PHY.
>>
>> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>  arch/arm/boot/dts/sunxi-h3-h5.dtsi | 3 ++-
>
>To avoid repeating the past, this patch, if approved, will be merged
>through the sunxi tree, not netdev nor net-next.
>
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
>b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
>> index 4b599b5d26f6..7aaa837c2388 100644
>> --- a/arch/arm/boot/dts/sunxi-h3-h5.dtsi
>> +++ b/arch/arm/boot/dts/sunxi-h3-h5.dtsi
>> @@ -421,7 +421,8 @@
>>                                 #address-cells = <1>;
>>                                 #size-cells = <0>;
>>                                 int_mii_phy: ethernet-phy@1 {
>> -                                       compatible =
>"ethernet-phy-ieee802.3-c22";
>> +                                       compatible =
>"allwinner,sun8i-h3-ephy",
>> +                                                      
>"ethernet-phy-ieee802.3-c22";
>
>Are you expecting people to override this properly?
>
>As it currently is, any external phy at address 1 will simply
>reuse the same device node. And if they don't override the
>property correctly, the driver will end up trying to use
>the internal phy, while the user is expecting the external
>one to be used.
>
>Maybe you could move this to some other address, maybe the last
>valid one, or second last valid one?

Some board designers may use other address.

For example, on Nano Pi NEO2 the PHY is attached at address 0x7.

>
>ChenYu
>
>>                                         reg = <1>;
>>                                         clocks = <&ccu CLK_BUS_EPHY>;
>>                                         resets = <&ccu RST_BUS_EPHY>;
>> --
>> 2.13.0
>>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
