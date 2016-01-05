From: Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 net-next 2/3] net: macb: Add NPx macb config using
 USRIO_DISABLED cap
Date: Tue, 5 Jan 2016 14:27:23 +0100
Message-ID: <568BC4BB.1030202@atmel.com>
References: <1451898103-21868-1-git-send-email-narmstrong@baylibre.com>
 <1451900573-22657-1-git-send-email-narmstrong@baylibre.com>
 <1451900573-22657-3-git-send-email-narmstrong@baylibre.com>
 <568A4BC0.2090005@atmel.com> <568BB522.4060905@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	<alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<joshc-acOepvfBmUk@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Rob Herring" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <568BB522.4060905-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 05/01/2016 13:20, Neil Armstrong a =E9crit :
> On 01/04/2016 11:38 AM, Nicolas Ferre wrote:
>> Le 04/01/2016 10:42, Neil Armstrong a =E9crit :
>>>  static const struct macb_config zynqmp_config =3D {
>>>  	.caps =3D MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
>>> @@ -2801,6 +2806,7 @@ static const struct of_device_id macb_dt_ids[=
] =3D {
>>>  	{ .compatible =3D "cdns,at32ap7000-macb" },
>>>  	{ .compatible =3D "cdns,at91sam9260-macb", .data =3D &at91sam9260=
_config },
>>>  	{ .compatible =3D "cdns,macb" },
>>> +	{ .compatible =3D "cdns,npx-macb", .data =3D &npx_config },
>>
>> I can accept that, but I think that you'd better make your device tr=
ee
>> compatibility string *not* generic. Name it by the first NPx SoC or
>> perfectly compatible SoC family that has this configuration and you'=
ll
>> be able to make the NP(x+1) compatible with it.
> Well, the first Soc having this configuration is Np4, would cdns,np4-=
macb be ok ?

Yes, absolutely.

Thanks

>> It has proven to be much more future proof and even if in the early =
days
>> of DT on ARM we accepted some binding with generic strings like this=
 one
>> below, It has proven to be a mistake.
>>
>>>  	{ .compatible =3D "cdns,gem", .data =3D &pc302gem_config },
>>>  	{ .compatible =3D "atmel,sama5d2-gem", .data =3D &sama5d2_config =
},
>>>
>>
>>
>=20
> Neil
>=20


--=20
Nicolas Ferre
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
