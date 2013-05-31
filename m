From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v2 0/6] Emaclite patches
Date: Fri, 31 May 2013 11:15:17 +0200
Message-ID: <51A86A25.6070309@monstr.eu>
References: <cover.1369909618.git.michal.simek@xilinx.com> <51A868FF.5070903@efe-gmbh.de>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2CQUBCPAAQDJFVRLNUQAC"
Cc: Michal Simek <michal.simek@xilinx.com>, netdev@vger.kernel.org
To: "Jens Renner (EFE)" <renner@efe-gmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:47288 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752925Ab3EaJPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 05:15:25 -0400
Received: by mail-ea0-f180.google.com with SMTP id g10so1375816eak.25
        for <netdev@vger.kernel.org>; Fri, 31 May 2013 02:15:24 -0700 (PDT)
In-Reply-To: <51A868FF.5070903@efe-gmbh.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2CQUBCPAAQDJFVRLNUQAC
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 05/31/2013 11:10 AM, Jens Renner (EFE) wrote:
> Am 30.05.2013 12:28, schrieb Michal Simek:
>> I have separated these emaclite patches from phy patches because it is=

>> easier for creating new versions.
>>
>> Thanks, Michal
>>
>> Changes in v2: - Fix __raw_iowrite() to pass correct parameters -
>> s/Corrent/Correct/ in patch description
>>
>> Michal Simek (6): net: emaclite: Report failures in mdio setup net:
>> emaclite: Support multiple phys connected to one MDIO bus net: emaclit=
e:
>> Let's make xemaclite_adjust_link static net: emaclite: Do not use
>> microblaze and ppc IO functions net: emaclite: Enable emaclite for Xil=
inx
>> Arm Zynq platform net: emaclite: Update driver header
>>
>> drivers/net/ethernet/xilinx/Kconfig           |   4 +-=20
>> drivers/net/ethernet/xilinx/xilinx_emaclite.c | 169
>> ++++++++++++++------------ 2 files changed, 95 insertions(+), 78
>> deletions(-)
>=20
> Works without problems on our Microblaze platform (as far as the patche=
s affect
> our functionality). MDIO verbosity has been tested ok.
>=20
>> @@ -862,8 +864,10 @@ static int xemaclite_mdio_setup(struct net_local =
*lp,
> struct device *dev)
>> XEL_MDIOCTRL_MDIOEN_MASK);
>>
>> bus =3D mdiobus_alloc(); -	if (!bus) +	if (!bus) { +		dev_err(dev, "Fa=
iled to
>> allocal mdiobus\n"); return -ENOMEM; +	}
>>
>> of_address_to_resource(np, 0, &res); snprintf(bus->id, MII_BUS_ID_SIZE=
,
>> "%.8llx",
>=20
> Shouldn't the wording be "allocate" instead of "allocal" in PATCH v2 1/=
6 (net:
> emaclite: Report failures in mdio setup)?

Ah yeah. Will you create patch to fix it?

Thanks,
Michal


--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2CQUBCPAAQDJFVRLNUQAC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGoaiUACgkQykllyylKDCEJxgCaAtkhwvAW7gYzza3sTuaqKEMG
IbMAn3F7WZ3guSXYLOGUsIoleKrAhtVB
=Vijt
-----END PGP SIGNATURE-----

------enig2CQUBCPAAQDJFVRLNUQAC--
