From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: emaclite: Fix typo in error message
Date: Mon, 03 Jun 2013 09:53:55 +0200
Message-ID: <51AC4B93.5010603@monstr.eu>
References: <51A87BB6.7060207@efe-gmbh.de> <51A87D32.9010006@monstr.eu> <20130531.163613.1343522161135384248.davem@davemloft.net>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2XBWJNLOPUJSFIJHODOFE"
Cc: renner@efe-gmbh.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f171.google.com ([209.85.215.171]:39256 "EHLO
	mail-ea0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751100Ab3FCHx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 03:53:59 -0400
Received: by mail-ea0-f171.google.com with SMTP id m14so565522eaj.2
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 00:53:58 -0700 (PDT)
In-Reply-To: <20130531.163613.1343522161135384248.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2XBWJNLOPUJSFIJHODOFE
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/01/2013 01:36 AM, David Miller wrote:
> From: Michal Simek <monstr@monstr.eu>
> Date: Fri, 31 May 2013 12:36:34 +0200
>=20
>> On 05/31/2013 12:30 PM, Jens Renner (EFE) wrote:
>>> s/allocal/allocate/
>>>
>>> Signed-off-by: Jens Renner <renner@efe-gmbh.de>
>>> ---
>>> drivers/net/ethernet/xilinx/xilinx_emaclite.c |    2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/=
net/ethernet/xilinx/xilinx_emaclite.c
>>> index aa14d8a..aaadf7e 100644
>>> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
>>> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
>>> @@ -877,7 +877,7 @@ static int xemaclite_mdio_setup(struct net_local =
*lp, struct device *dev)
>>>
>>>         bus =3D mdiobus_alloc();
>>>         if (!bus) {
>>> -               dev_err(dev, "Failed to allocal mdiobus\n");
>>> +               dev_err(dev, "Failed to allocate mdiobus\n");
>>>                 return -ENOMEM;
>>>         }
>>
>> Acked-by: Michal Simek <monstr@monstr.eu>
>=20
> You're acking a patch that is corrupted by the submitter's email client=

> and won't even apply :-)

:-) He has sent another email regarding to phy handling and
I have applied it, resolved conflicts on the top of my emaclite changes
and I thought that it was caused by my changes not because of corrupted
patch. That's why I have also tested it.
For this particular case, I didn't try to apply it just wanted to let you=

know that I agree with this change because it fixes my typo.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2XBWJNLOPUJSFIJHODOFE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGsS5QACgkQykllyylKDCE4FQCePVhPZSgcc1u25koUqLhiB22h
EI0An1vLAUDauyOvh0Z3vMtxMlEK4oA5
=WIvN
-----END PGP SIGNATURE-----

------enig2XBWJNLOPUJSFIJHODOFE--
