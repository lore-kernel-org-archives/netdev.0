From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH v4 net-next 2/3] net: macb: Add NPx macb config using
 USRIO_DISABLED cap
Date: Tue, 5 Jan 2016 13:20:50 +0100
Message-ID: <568BB522.4060905@baylibre.com>
References: <1451898103-21868-1-git-send-email-narmstrong@baylibre.com>
 <1451900573-22657-1-git-send-email-narmstrong@baylibre.com>
 <1451900573-22657-3-git-send-email-narmstrong@baylibre.com>
 <568A4BC0.2090005@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Nicolas Ferre <nicolas.ferre@atmel.com>, davem@davemloft.net,
	harini.katakam@xilinx.com, boris.brezillon@free-electrons.com,
	alexandre.belloni@free-electrons.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, joshc@ni.com, devicetree@vger.kernel.org,
	Rob Herring <robh+dt@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <568A4BC0.2090005@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/04/2016 11:38 AM, Nicolas Ferre wrote:
> Le 04/01/2016 10:42, Neil Armstrong a =E9crit :
>>  static const struct macb_config zynqmp_config =3D {
>>  	.caps =3D MACB_CAPS_GIGABIT_MODE_AVAILABLE | MACB_CAPS_JUMBO,
>> @@ -2801,6 +2806,7 @@ static const struct of_device_id macb_dt_ids[]=
 =3D {
>>  	{ .compatible =3D "cdns,at32ap7000-macb" },
>>  	{ .compatible =3D "cdns,at91sam9260-macb", .data =3D &at91sam9260_=
config },
>>  	{ .compatible =3D "cdns,macb" },
>> +	{ .compatible =3D "cdns,npx-macb", .data =3D &npx_config },
>=20
> I can accept that, but I think that you'd better make your device tre=
e
> compatibility string *not* generic. Name it by the first NPx SoC or
> perfectly compatible SoC family that has this configuration and you'l=
l
> be able to make the NP(x+1) compatible with it.
Well, the first Soc having this configuration is Np4, would cdns,np4-ma=
cb be ok ?
>=20
> It has proven to be much more future proof and even if in the early d=
ays
> of DT on ARM we accepted some binding with generic strings like this =
one
> below, It has proven to be a mistake.
>=20
>>  	{ .compatible =3D "cdns,gem", .data =3D &pc302gem_config },
>>  	{ .compatible =3D "atmel,sama5d2-gem", .data =3D &sama5d2_config }=
,
>>
>=20
>=20

Neil
