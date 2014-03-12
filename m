From: Michal Simek <monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org>
Subject: Re: [PATCH v5] can: xilinx CAN controller support.
Date: Wed, 12 Mar 2014 11:18:51 +0100
Message-ID: <5320348B.7030401@monstr.eu>
References: <5254bfec-c6fd-4681-a34d-706d51e60fbb@VA3EHSMHS004.ehs.local> <531DD2C4.5060109@pengutronix.de> <f1e2f08f-05fc-40d3-8437-4c6817d631cb@AM1EHSMHS010.ehs.local> <531F0636.4050608@pengutronix.de> <a99feda0-7463-4781-bb73-90b99e65b014@CO9EHSMHS028.ehs.local> <531F1E30.4040203@pengutronix.de>
Reply-To: monstr-pSz03upnqPeHXe+LvDLADg@public.gmane.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Sgn1ffuOiCEaJoCe2LrWcuSawPMniLp35"
Cc: Appana Durga Kedareswara Rao <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	"fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Soren Brinkmann <sorenb-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <531F1E30.4040203-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Sgn1ffuOiCEaJoCe2LrWcuSawPMniLp35
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi guys,


On 03/11/2014 03:31 PM, Marc Kleine-Budde wrote:
> On 03/11/2014 03:08 PM, Appana Durga Kedareswara Rao wrote:
>=20
>>>>>> +   struct napi_struct napi;
>>>>>> +   u32 (*read_reg)(const struct xcan_priv *priv, enum xcan_reg re=
g);
>>>>>> +   void (*write_reg)(const struct xcan_priv *priv, enum xcan_reg =
reg,
>>>>>> +                   u32 val);
>>>>>> +   struct net_device *dev;
>>>>>> +   void __iomem *reg_base;
>>>>>> +   unsigned long irq_flags;
>>>>>> +   struct clk *aperclk;
>>>>>> +   struct clk *devclk;
>>>>>
>>>>> Please rename the clock variables to match the names in the DT.
>>>>>
>>>> The clock names are different for axi CAN and CANPS case.
>>>> So will make them as busclk and devclk Are you ok with this?
>>>
>>> Why not "ref_clk" and "aper_clk" as used in the DT?
>>>
>> One of the comments I got from the Soren(sorenb-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org)
>> Is the  clock-names must match the data sheet.
>> If I Modify the clock names then it is different names for AXI CAN
>> and CANPS case.
>=20
> Sorry, my faul, I thought the names are already these from the
> datasheet. As S=C3=B6ren pointed out please use 's_axi_aclk' and
> 'can_clk' for the DT and for the the variable names in the private
> struct, too.
>=20
> The 'official' name of the ip core seems to be axi_can, should we renam=
e
> the driver? I suspect, that Michal wants to keep xilinx in the name for=

> marketing reasons :P

I hope that I am not moving to marketing position.  :-)

opb_can, plb_can, axi_can, amba_can are all valid options for this IP.

Maybe in future Xilinx will decide to use different bus and then will jus=
t move
all current soft IPs to new bus and drivers will be compatible.
This is exactly what happened when Xilinx moved from OPB to PLB and then
from PLB to AXI.
That's why I think in general having bus name in name doesn't fit for our=
 case.

The same is for clock name which has bus name in it.
For PLB it was called SPLB_Clk and I don't have OPB version but
at least standalone driver points to OPB version where I believe
SPLB_Clk name was not used.

That's why if you want to reflect that clock is coming from bus
you should use any generic name. At least for these soft IPs
and this one is special because it is one which also went to silicon.
Next example is XADC.

That's why I just don't think we can find out better name than
xilinx_can.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--Sgn1ffuOiCEaJoCe2LrWcuSawPMniLp35
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlMgNIsACgkQykllyylKDCHXSACgmyMdFBH6GwD+LJ0d48RL3/RP
GvoAn3C02g7HHk2naYPJJiN3eJrwSizK
=6Dns
-----END PGP SIGNATURE-----

--Sgn1ffuOiCEaJoCe2LrWcuSawPMniLp35--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
