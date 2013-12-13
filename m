From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: [PATCH 07/10] ARM: dts: sun7i: cubietruck: Enable
 the GMAC
Date: Fri, 13 Dec 2013 11:21:56 +0100
Message-ID: <52AADFC4.1070003@st.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org> <1386350983-13281-8-git-send-email-wens@csie.org> <CAGVrzcb_r9_p4urz4XkE2A-G85KAHJa4PJ=Gt9a4RPYQNJ6j0g@mail.gmail.com> <CAGb2v64yFhkTXvdq=1VpemULhXew-5fvmSoTBzEb6iFDiSqy1Q@mail.gmail.com> <CAGVrzcaxV88dU3vEVGUiEQihUHLxq+QvQVQ6VvmOFVRsqbbX7w@mail.gmail.com>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-sunxi+bncBDB4X24GTMHRB4N7VOKQKGQEPL7QBVY-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <CAGVrzcaxV88dU3vEVGUiEQihUHLxq+QvQVQ6VvmOFVRsqbbX7w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 12/7/2013 2:57 AM, Florian Fainelli wrote:
> 2013/12/6 Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>:
>> On Sat, Dec 7, 2013 at 5:09 AM, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>>> 2013/12/6 Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>:
>>>> The CubieTruck uses the GMAC with an RGMII phy.
>>>>
>>>> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
>>>> ---
>>>>   arch/arm/boot/dts/sun7i-a20-cubietruck.dts | 8 ++++++++
>>>>   1 file changed, 8 insertions(+)
>>>>
>>>> diff --git a/arch/arm/boot/dts/sun7i-a20-cubietruck.dts b/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
>>>> index 8a1009d..af212a2 100644
>>>> --- a/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
>>>> +++ b/arch/arm/boot/dts/sun7i-a20-cubietruck.dts
>>>> @@ -33,6 +33,14 @@
>>>>                          pinctrl-0 = <&uart0_pins_a>;
>>>>                          status = "okay";
>>>>                  };
>>>> +
>>>> +               gmac: ethernet@01c50000 {
>>>> +                       pinctrl-names = "default";
>>>> +                       pinctrl-0 = <&gmac_pins_rgmii>;
>>>> +                       snps,phy-addr = <1>;
>>>
>>> What is this snps,phy-addr property? Why is not a standard device tree
>>> node for an Ethernet PHY node used?
>>
>> This property is implemented by stmmac and documented in the DT
>> bindings. stmmac has not been updated to use Ethernet PHY nodes.
>
> This driver property should be removed and deprecated since there is
> an ePAPR standardized Ethernet PHY node. What I am worried here is the
> loss of information, the standard Ethernet DT node allows to specify
> much more information (clause, maximum speed, compatible string
> etc...).


yes Florian you are right and I have already started updating the
driver. I do not sure that I'll be able to send all the patches soon
but for sure I can re-base them.

>>
>> Removing this property will not affect the function of the driver.
>> The driver probes its MDIO bus and selects the lowest available
>> address if not specified.
>
> So if this is just giving the driver a hint on where to  probe for a
> PHY on the MDIO bus, then let's drop it and use the standard DT node
> no?
>
>>
>>>> +                       phy-mode = "rgmii";
>>>
>>> Especially since you use the relatively standard "phy-mode" property here?
>>
>> Used as specified in stmmac DT bindings.
>
> That one is kind of okay because of_get_phy_mode() knows about it,
> even though ePAPR states this should be "phy-connection-type", so I am
> okay with keeping that one because current practice and helpers are
> here.
>
