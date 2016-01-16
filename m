From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10GBASE-KR
Date: Fri, 15 Jan 2016 18:59:29 -0800
Message-ID: <5699B211.5070602@gmail.com>
References: <1452759839-9874-1-git-send-email-shh.xie@gmail.com>
 <20160114164418.GD19773@lunn.ch>
 <VI1PR04MB166491DEBB439EB72742201DE8CD0@VI1PR04MB1664.eurprd04.prod.outlook.com>
 <56997951.90304@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Shaohui Xie <Shaohui.Xie-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Shaohui Xie <shaohui.xie-3arQi8VN3Tc@public.gmane.org>,
	Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
	"shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <56997951.90304-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 15/01/2016 14:57, Sebastian Hesselbarth a =C3=A9crit :
> On 15.01.2016 05:01, Shaohui Xie wrote:
>>> -----Original Message-----
>>> From: Andrew Lunn [mailto:andrew-g2DYL2Zd6BY@public.gmane.org]
>>> Sent: Friday, January 15, 2016 12:44 AM
>>> To: shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
>>> Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linuxppc-
>>> dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org; f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; Sh=
aohui Xie
>>> Subject: Re: [PATCH 1/3][v2] net: phy: introduce 1000BASE-KX and 10=
GBASE-KR
>>>
>>> On Thu, Jan 14, 2016 at 04:23:59PM +0800, shh.xie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org wrote:
>>>> From: Shaohui Xie <Shaohui.Xie-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>>>
>>>> This commit adds necessary definitions for the PHY layer to recogn=
ize
>>>> backplane Ethernet 1000BASE-KX and 10GBASE-KR as valid PHY interfa=
ces,
>>>> "1000base-kx" for 1000BASE-KX, "10gbase-kr" for 10GBASE-KR.
>>>>
>>>> Signed-off-by: Shaohui Xie <Shaohui.Xie-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
>>>> ---
>>>> changes in v2:
>>>> new patch.
>=20
> Shaohui,
>=20
> it would be more useful to describe _what_ is new here compared to v1=
=2E
>=20
> Anyway:
>=20
>>>>  Documentation/devicetree/bindings/net/ethernet.txt | 4 ++--
>>>>  include/linux/phy.h                                | 6 ++++++
>>>>  2 files changed, 8 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/Documentation/devicetree/bindings/net/ethernet.txt
>>>> b/Documentation/devicetree/bindings/net/ethernet.txt
>>>> index 5d88f37..1166a5c 100644
>>>> --- a/Documentation/devicetree/bindings/net/ethernet.txt
>>>> +++ b/Documentation/devicetree/bindings/net/ethernet.txt
>>>> @@ -11,8 +11,8 @@ The following properties are common to the Ether=
net
>>> controllers:
>>>>    the maximum frame size (there's contradiction in ePAPR).
>>>>  - phy-mode: string, operation mode of the PHY interface; supporte=
d values are
>>>>    "mii", "gmii", "sgmii", "qsgmii", "tbi", "rev-mii", "rmii",
>>>> "rgmii", "rgmii-id",
>>>> -  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii"; this is no=
w a
>>>> de-facto
>>>> -  standard property;
>>>> +  "rgmii-rxid", "rgmii-txid", "rtbi", "smii", "xgmii", "1000base-=
kx",
>>>> + "10gbase-kr";  this is now a de-facto standard property;
>>>
>>> I know very little about this, so i'm just asking a question. None =
of the other
>>> interface modes contain a bit rate. So is the bit rate needed for y=
our two new
>>> modes?
>>
>> 1000BASE-KX and 10GBASE-KR are terms in IEEE802.3, so as XGMII and G=
MII.=20
>> There are interfaces could be different bit rates but same types,=20
>> e.g. 100BASE-LX10 and 1000BASE-LX10, or 40GBASE-KR4 and 100GBASE-KR4=
,=20
>> having bit rate is clear to represent hardware.
>>
>=20
> If you look at the list of possible values for "phy-mode" you'd see t=
hat
> none of it describes a PHY-to-PHY connection but all are for MAC-to-P=
HY
> connections. Also, names above suggest it already: MII is short for
> media _independent_ interface.
>=20
> I copy Andrew's concerns and think that neither 10000base-kx nor
> 10gbase-kr belong in the list of phy-mode properties.

I concur with that as well, if the phy connection does not really matte=
r
here, or does not seem like a good fit, maybe we should have a differen=
t
property, or just define the hardware interface a little differently?
--=20
=46lorian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
