From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 07/10] ARM: dts: sun7i: cubietruck: Enable
 the GMAC
Date: Mon, 9 Dec 2013 09:48:01 -0800
Message-ID: <CAGVrzcaVJtoVhEfV+ZiMOkm3F8NBCf2YRcZSrZPMRfQfEr1u=g@mail.gmail.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org>
 <1386350983-13281-8-git-send-email-wens@csie.org> <CAGVrzcb_r9_p4urz4XkE2A-G85KAHJa4PJ=Gt9a4RPYQNJ6j0g@mail.gmail.com>
 <CAGb2v64yFhkTXvdq=1VpemULhXew-5fvmSoTBzEb6iFDiSqy1Q@mail.gmail.com>
 <CAGVrzcaxV88dU3vEVGUiEQihUHLxq+QvQVQ6VvmOFVRsqbbX7w@mail.gmail.com> <CAGb2v675Cg6S512zfM1z4b+wqE_PesDGWdgcmpzWmPzyzXqbeA@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi <linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBCH67JWTV4DBB64ETCKQKGQEWQ5HXUI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <CAGb2v675Cg6S512zfM1z4b+wqE_PesDGWdgcmpzWmPzyzXqbeA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

2013/12/8 Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>:
> Florian, Giuseppe:
>
> On Sat, Dec 7, 2013 at 9:57 AM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> 2013/12/6 Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>:
>>> On Sat, Dec 7, 2013 at 5:09 AM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>>> 2013/12/6 Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>:
>>>>> The CubieTruck uses the GMAC with an RGMII phy.
>>>>>
>>>>> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
>>>>> ---
>>>>>  arch/arm/boot/dts/sun7i-a20-cubietruck.dts | 8 ++++++++
>>>>>  1 file changed, 8 insertions(+)
>>>>>
>>>>> diff --git a/arch/arm/boot/dts/sun7i-a20-cubietruck.dts b/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
>>>>> index 8a1009d..af212a2 100644
>>>>> --- a/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
>>>>> +++ b/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
>>>>> @@ -33,6 +33,14 @@
>>>>>                         pinctrl-0 = <&uart0_pins_a>;
>>>>>                         status = "okay";
>>>>>                 };
>>>>> +
>>>>> +               gmac: ethernet@01c50000 {
>>>>> +                       pinctrl-names = "default";
>>>>> +                       pinctrl-0 = <&gmac_pins_rgmii>;
>>>>> +                       snps,phy-addr = <1>;
>>>>
>>>> What is this snps,phy-addr property? Why is not a standard device tree
>>>> node for an Ethernet PHY node used?
>>>
>>> This property is implemented by stmmac and documented in the DT
>>> bindings. stmmac has not been updated to use Ethernet PHY nodes.
>>
>> This driver property should be removed and deprecated since there is
>> an ePAPR standardized Ethernet PHY node. What I am worried here is the
>> loss of information, the standard Ethernet DT node allows to specify
>> much more information (clause, maximum speed, compatible string
>> etc...).
>
> Giuseppe, any thoughts on this?
>
>>> Removing this property will not affect the function of the driver.
>>> The driver probes its MDIO bus and selects the lowest available
>>> address if not specified.
>>
>> So if this is just giving the driver a hint on where to  probe for a
>> PHY on the MDIO bus, then let's drop it and use the standard DT node
>> no?
>
> Sure. I will remove it from the DT.
>
> The stmmac driver does not have a seperate MDIO bus driver, nor
> does it support Ethernet PHY node bindings. So I will not add
> a phy node at this moment.

This will create needless churn in the DT if you do not do it now,
worse actually, we switch from a DT which specifically described
Ethernet PHY nodes properly to a version where it does, to ultimately
a newer version which does.

Considering that the absence of a "snps,phy-addr" property will still
result in the MDIO bus to be probed, keeping the existing Ethernet PHY
nodes, referencing them correclty with a "phy-handle" property, but
having no explicit support for these in the driver will not result in
a functional change, and will reduce the DT churn. Also, you could
still sneak a patch in this patchset which parses the standard
EThernet PHY node binding.

>
>>>>> +                       phy-mode = "rgmii";
>>>>
>>>> Especially since you use the relatively standard "phy-mode" property here?
>>>
>>> Used as specified in stmmac DT bindings.
>>
>> That one is kind of okay because of_get_phy_mode() knows about it,
>> even though ePAPR states this should be "phy-connection-type", so I am
>> okay with keeping that one because current practice and helpers are
>> here.
>
> It seems all ARM DTs currently use "phy-mode".

Which is why I said "is kind of okay", but this is not what the
standard came up with, ARM is not exactly the best DT-citizen out
there as people are prone to making up new properties when the
standard already defines some, anyway....
--
Florian
