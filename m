From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH v2 2/3] netdev/of/phy: Add MDIO bus multiplexer support.
Date: Wed, 28 Sep 2011 19:32:16 +0200
Message-ID: <CAHXqBF+ZVbCGEvnCcOtHk+sOWFLp1CuEnGLq+GEtHQTpu9PuYg@mail.gmail.com>
References: <1317166015-20714-1-git-send-email-david.daney@cavium.com>
 <1317166015-20714-3-git-send-email-david.daney@cavium.com>
 <CAHXqBFLzrkH4AJVozbtT4k7ccgVgfaPoq69J48DeSJKSwEtxHw@mail.gmail.com> <4E8350A8.7090307@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: David Daney <david.daney@cavium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4E8350A8.7090307@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

W dniu 28 wrze=B6nia 2011 18:51 u=BFytkownik David Daney
<david.daney@cavium.com> napisa=B3:
> On 09/28/2011 12:25 AM, Micha=B3 Miros=B3aw wrote:
>>
>> 2011/9/28 David Daney<david.daney@cavium.com>:
>> [...]
>>>
>>> +Example :
>>> +
>>> + =A0 =A0 =A0 /* The parent MDIO bus. */
>>> + =A0 =A0 =A0 smi1: mdio@1180000001900 {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "cavium,octeon-3860-md=
io";
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 #address-cells =3D<1>;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 #size-cells =3D<0>;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 reg =3D<0x11800 0x00001900 0x0 0x40>;
>>> + =A0 =A0 =A0 };
>>> +
>>> + =A0 =A0 =A0 /*
>>> + =A0 =A0 =A0 =A0 =A0An NXP sn74cbtlv3253 dual 1-of-4 switch contro=
lled by a
>>> + =A0 =A0 =A0 =A0 =A0pair of GPIO lines. =A0Child busses 2 and 3 po=
pulated with 4
>>> + =A0 =A0 =A0 =A0 =A0PHYs each.
>>> + =A0 =A0 =A0 =A0*/
>>> + =A0 =A0 =A0 mdio-mux {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 compatible =3D "cavium,mdio-mux-sn74c=
btlv3253",
>>> "cavium,mdio-mux";
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 gpios =3D<&gpio1 3 0>,<&gpio1 4 0>;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio-parent-bus =3D<&smi1>;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 #address-cells =3D<1>;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 #size-cells =3D<0>;
>>
>> This should probably have 'compatible =3D "nxp,sn74cbtlv3253";' here=
=2E
>>
>
> No, the sn74cbtlv3253 is a general purpose part that could be used to
> multiplex anything (I2C, SPI, random analog signals, etc.). =A0Only w=
hen it is
> in the "cavium,mdio-mux-sn74cbtlv3253" configuration is it an MDIO bu=
s
> multiplexer.

This should use some generic name then. 'mdio-mux-gpio' or something.
There's no point in introducing chip's model for a gate-like discrete
device.

Best Regards,
Micha=B3 Miros=B3aw
