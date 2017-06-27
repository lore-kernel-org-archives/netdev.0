From: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Subject: Re: [PATCH v6 05/21] net-next: stmmac: Add dwmac-sun8i
Date: Tue, 27 Jun 2017 18:22:24 +0800
Message-ID: <CAGb2v64-Ua20V7nrM8YzAMxWQdJqE8SM4uvz6Bi47LQErJ1qcA@mail.gmail.com>
References: <20170531071852.12422-1-clabbe.montjoie@gmail.com>
 <20170531071852.12422-6-clabbe.montjoie@gmail.com> <8e3d73a7-e9ff-d3e2-4bce-bcc79cdf86db@arm.com>
 <20170627080529.GA2468@Red> <CAGb2v65mhDN9vXe6DE2cZPW1BzgYPwK+D2U5VFgyr0wVVZZqDQ@mail.gmail.com>
 <20170627082103.GB2468@Red> <530f7b3e-247d-2e4d-8174-ce6195bacf5b@arm.com>
 <20170627094111.supxmzf2k3n3ewec@flea.lan> <44afb371-44d4-dbb5-0aac-4bbc55269344@arm.com>
Reply-To: wens-jdAy2FN1RRM@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>, Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
	Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>, Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, alexandre.torgue-qxv4g6HH51o@public.gmane.org,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, Icenowy Zheng <icenowy-h8G6r0blFSE@public.gmane.org>,
	david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, =?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
To: Andre Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org>
Return-path: <linux-sunxi+bncBCMILY6JWQBBB6PDZDFAKGQEPXCJ2JI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <44afb371-44d4-dbb5-0aac-4bbc55269344-5wv7dgnIgG8@public.gmane.org>
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On Tue, Jun 27, 2017 at 6:15 PM, Andre Przywara <andre.przywara-5wv7dgnIgG8@public.gmane.org> wr=
ote:
> Hi,
>
> On 27/06/17 10:41, Maxime Ripard wrote:
>> On Tue, Jun 27, 2017 at 10:02:45AM +0100, Andre Przywara wrote:
>>> Hi,
>>>
>>> (CC:ing some people from that Rockchip dmwac series)
>>>
>>> On 27/06/17 09:21, Corentin Labbe wrote:
>>>> On Tue, Jun 27, 2017 at 04:11:21PM +0800, Chen-Yu Tsai wrote:
>>>>> On Tue, Jun 27, 2017 at 4:05 PM, Corentin Labbe
>>>>> <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>>>> On Mon, Jun 26, 2017 at 01:18:23AM +0100, Andr=C3=A9 Przywara wrote:
>>>>>>> On 31/05/17 08:18, Corentin Labbe wrote:
>>>>>>>> The dwmac-sun8i is a heavy hacked version of stmmac hardware by
>>>>>>>> allwinner.
>>>>>>>> In fact the only common part is the descriptor management and the =
first
>>>>>>>> register function.
>>>>>>>
>>>>>>> Hi,
>>>>>>>
>>>>>>> I know I am a bit late with this, but while adapting the U-Boot dri=
ver
>>>>>>> to the new binding I was wondering about the internal PHY detection=
:
>>>>>>>
>>>>>>>
>>>>>>> So here you seem to deduce the usage of the internal PHY by the PHY
>>>>>>> interface specified in the DT (MII =3D internal, RGMII =3D external=
).
>>>>>>> I think I raised this question before, but isn't it perfectly legal=
 for
>>>>>>> a board to use MII with an external PHY even on those SoCs that fea=
ture
>>>>>>> an internal PHY?
>>>>>>> On the first glance that does not make too much sense, but apart fr=
om
>>>>>>> not being the correct binding to describe all of the SoCs features =
I see
>>>>>>> two scenarios:
>>>>>>> 1) A board vendor might choose to not use the internal PHY because =
it
>>>>>>> has bugs, lacks features (configurability) or has other issues. For
>>>>>>> instance I have heard reports that the internal PHY makes the SoC g=
o
>>>>>>> rather hot, possibly limiting the CPU frequency. By using an extern=
al
>>>>>>> MII PHY (which are still cheaper than RGMII PHYs) this can be avoid=
ed.
>>>>>>> 2) A PHY does not necessarily need to be directly connected to
>>>>>>> magnetics. Indeed quite some boards use (RG)MII to connect to a swi=
tch
>>>>>>> IC or some other network circuitry, for instance fibre connectors.
>>>>>>>
>>>>>>> So I was wondering if we would need an explicit:
>>>>>>>       allwinner,use-internal-phy;
>>>>>>> boolean DT property to signal the usage of the internal PHY?
>>>>>>> Alternatively we could go with the negative version:
>>>>>>>       allwinner,disable-internal-phy;
>>>>>>>
>>>>>>> Or what about introducing a new "allwinner,internal-mii-phy" compat=
ible
>>>>>>> string for the *PHY* node and use that?
>>>>>>>
>>>>>>> I just want to avoid that we introduce a binding that causes us
>>>>>>> headaches later. I think we can still fix this with a followup patc=
h
>>>>>>> before the driver and its binding hit a release kernel.
>>>>>>>
>>>>>>> Cheers,
>>>>>>> Andre.
>>>>>>>
>>>>>>
>>>>>> I just see some patch, where "phy-mode =3D internal" is valid.
>>>>>> I will try to find a way to use it
>>>>>
>>>>> Can you provide a link?
>>>>
>>>> https://lkml.org/lkml/2017/6/23/479
>>>>
>>>>>
>>>>> I'm not a fan of using phy-mode for this. There's no guarantee what
>>>>> mode the internal PHY uses. That's what phy-mode is for.
>>>
>>> I can understand Chen-Yu's concerns, but ...
>>>
>>>> For each soc the internal PHY mode is know and setted in emac_variant/=
internal_phy
>>>> So its not a problem.
>>>
>>> that is true as well, at least for now.
>>>
>>> So while I agree that having a separate property to indicate the usage
>>> of the internal PHY would be nice, I am bit tempted to use this easier
>>> approach and piggy back on the existing phy-mode property.
>>
>> We're trying to fix an issue that works for now too.
>>
>> If we want to consider future weird cases, then we must consider all
>> of them. And the phy mode changing is definitely not really far
>> fetched.
>>
>> I agree with Chen-Yu, and I really feel like the compatible solution
>> you suggested would cover both your concerns, and ours.
>
> So something like this?
>         emac: emac@1c30000 {
>             compatible =3D "allwinner,sun8i-h3-emac";
>             ...
>             phy-mode =3D "mii";
>             phy-handle =3D <&int_mii_phy>;
>             ...
>
>             mdio: mdio {
>                 #address-cells =3D <1>;
>                 #size-cells =3D <0>;
>                 int_mii_phy: ethernet-phy@1 {
>                     compatible =3D "allwinner,sun8i-h3-ephy";
>                     syscon =3D <&syscon>;
>                     reg =3D <1>;
>                     clocks =3D <&ccu CLK_BUS_EPHY>;
>                     resets =3D <&ccu RST_BUS_EPHY>;
>                 };
>             };
>         };
>
> And then move the internal-PHY setup code into a separate PHY driver?
>
> That looks like the architecturally best solution to me, but is probably
> also a bit involved since it would require a separate PHY driver.
> Or can we make it simpler, but still use this binding?

This was my initial approach prior to handing it off to Corentin.

The MDIO bus is discoverable, so in the kernel MDIO bus driver code, the
devices are only created if something responds. However, for the EPHY to
respond, you must first configure the clocks, reset controls, and syscon
registers. You need either a platform device driver for that, or do it
in the MAC driver. The latter made more sense at the time, looking at
how the device tree is structured.

ChenYu

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
