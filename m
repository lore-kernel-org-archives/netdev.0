From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Re: [PATCH 2/4] dt-bindings: add binding for
 RTL8211E Ethernet PHY
Date: Mon, 21 Aug 2017 12:54:40 -0700
Message-ID: <8384069c-15f1-9fcd-770f-05d54d183e9e@gmail.com>
References: <20170421232436.10924-1-icenowy@aosc.io>
 <20170421232436.10924-3-icenowy@aosc.io>
 <c7aa9d7a-5e97-0e7f-2b1c-584a4de00837@gmail.com>
 <edf26d7de605a93bfce258de0353df6d@aosc.io>
 <a455c822-d5aa-3f66-03c5-4d1268f9104b@gmail.com>
 <D714E47B-D6B2-4C9F-B9D7-FB9D170E0ADF@aosc.io>
 <068f1323-3864-620c-0deb-6c5e04a9e498@gmail.com>
 <19ad1316a74e344d3e1c783458eb4d59@aosc.io>
Reply-To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
To: icenowy-h8G6r0blFSE@public.gmane.org
Return-path: <linux-sunxi+bncBCH67JWTV4DBBBPV5TGAKGQEMQKNANI-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
In-Reply-To: <19ad1316a74e344d3e1c783458eb4d59-h8G6r0blFSE@public.gmane.org>
Content-Language: en-US
List-Post: <https://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <https://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <https://groups.google.com/group/linux-sunxi
List-Subscribe: <https://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
 <https://groups.google.com/group/linux-sunxi/subscribe>
List-Id: netdev.vger.kernel.org

On 08/21/2017 07:53 AM, icenowy-h8G6r0blFSE@public.gmane.org wrote:
> =E5=9C=A8 2017-05-05 02:29=EF=BC=8CFlorian Fainelli =E5=86=99=E9=81=93=EF=
=BC=9A
>> On 05/04/2017 11:26 AM, Icenowy Zheng wrote:
>>>
>>>
>>> =E4=BA=8E 2017=E5=B9=B45=E6=9C=885=E6=97=A5 GMT+08:00 =E4=B8=8A=E5=8D=
=882:21:29, Florian Fainelli
>>> <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> =E5=86=99=E5=88=B0:
>>>> On 05/04/2017 11:10 AM, icenowy-h8G6r0blFSE@public.gmane.org wrote:
>>>>> =E5=9C=A8 2017-04-22 08:22=EF=BC=8CFlorian Fainelli =E5=86=99=E9=81=
=93=EF=BC=9A
>>>>>> On 04/21/2017 04:24 PM, Icenowy Zheng wrote:
>>>>>>> From: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
>>>>>>>
>>>>>>> Some RTL8211E Ethernet PHY have an issue that needs a workaround
>>>>>>> indicated with device tree.
>>>>>>>
>>>>>>> Add the binding for a property that indicates this workaround.
>>>>>>>
>>>>>>> Signed-off-by: Icenowy Zheng <icenowy-ymACFijhrKM@public.gmane.org>
>>>>>>> ---
>>>>>>>  .../devicetree/bindings/net/realtek,rtl8211e.txt   | 22
>>>>>>> ++++++++++++++++++++++
>>>>>>>  1 file changed, 22 insertions(+)
>>>>>>>  create mode 100644
>>>>>>> Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
>>>>>>>
>>>>>>> diff --git
>>>>>>> a/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
>>>>>>> b/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
>>>>>>> new file mode 100644
>>>>>>> index 000000000000..c1913301bfe8
>>>>>>> --- /dev/null
>>>>>>> +++ b/Documentation/devicetree/bindings/net/realtek,rtl8211e.txt
>>>>>>> @@ -0,0 +1,22 @@
>>>>>>> +Realtek RTL8211E Ethernet PHY
>>>>>>> +
>>>>>>> +One batch of RTL8211E is slight broken, that needs some special
>>>> (and
>>>>>>> +full of magic numbers) tweaking in order to make GbE to operate
>>>>>>> properly.
>>>>>>> +The only well-known board that used the broken batch is Pine64+.
>>>>>>> +Configure it through an Ethernet OF device node.
>>>>>>> +
>>>>>>> +Optional properties:
>>>>>>> +
>>>>>>> +- realtek,disable-rx-delay:
>>>>>>> +  If set, RX delay will be completely disabled (according to
>>>>>>> Realtek). This
>>>>>>> +  will affect the performance on non-broken boards.
>>>>>>> +  default: do not disable RX delay.
>>>>>>
>>>>>> Please don't introduce custom properties to do that, instead correct
>>>>>> specify the "phy-mode" such that it is e.g: "rgmii-txid" which
>>>> indicates
>>>>>> that there should be no RX internal delay, but a TX internal delay
>>>> added
>>>>>> by the PHY.
>>>>>
>>>>> Checked the document, the meaning of "rgmii-txid" is not correct
>>>> here.
>>>>>
>>>>> This doesn't effect the MAC, and the MAC should still add TX delay.
>>>>>
>>>>> The definition of "rgmii-txid" in
>>>>> Documentation/devicetree/binding/net/ethernet.txt is "RGMII with
>>>>> internal TX delay provided by the PHY, the MAC should not add an TX
>>>> delay
>>>>> in this case". However, this do not indicate that the MAC doesn't add
>>>> TX
>>>>> delay; in fact that just totally disabled the PHY to provide the RX
>>>> delay.
>>>>> MAC still should to add delay on both TX/RX, which is the semantic of
>>>>> standard "rgmii".
>>>>>
>>>>> So I cannot used "rgmii-txid" here, but should continue to use this
>>>>> custom property.
>=20
> Sorry for replying an old email, but it's because the driver of the MAC I
> used is merged (dwmac-sun8i).
>=20
> The driver of the MAC currently only supports "mii", "rmii", and "rgmii",
> and according to the SoC's user manual, the MAC cannot has its delays
> disabled.
>=20
> How should it handle this "rgmii-txid" here? Just treat it as "rgmii"?

Considering there are no configurable delays on the MAC side, all you
can do is treat all RGMII variants the same by configuring the MAC for
RGMII mode (with no additional capabilities and as opposed to MII, RMII
which are other clocking/data pins modes) and let the PHY configure the
delay accordingly based on "phy-mode"/phy_interface_t. You can use
phy_interface_is_rgmii() as a helper function to cover all 4 variants.
--=20
Florian

--=20
You received this message because you are subscribed to the Google Groups "=
linux-sunxi" group.
To unsubscribe from this group and stop receiving emails from it, send an e=
mail to linux-sunxi+unsubscribe-/JYPxA39Uh5TLH3MbocFF+G/Ez6ZCGd0@public.gmane.org
For more options, visit https://groups.google.com/d/optout.
