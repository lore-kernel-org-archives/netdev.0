From: Sven Anders <anders@anduras.de>
Subject: Re: Possible bug in bonding driver (with VLAN in ALB mode)
Date: Tue, 21 Oct 2008 22:34:41 +0200
Message-ID: <48FE3CE1.3080906@anduras.de>
References: <48FE0EEB.7050503@anduras.de> <1830.1224612755@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE7C019895E41A2B68DFDA772"
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metropolitan.anduras.de ([80.237.200.159]:59140 "EHLO
	metropolitan.anduras.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751056AbYJUUet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 16:34:49 -0400
In-Reply-To: <1830.1224612755@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE7C019895E41A2B68DFDA772
Content-Type: multipart/mixed;
 boundary="------------090507080409070305020800"

This is a multi-part message in MIME format.
--------------090507080409070305020800
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

Jay Vosburgh schrieb:

> Can you try this patch and tell me if it fixes the problem?
>=20
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_=
alb.c
> index ade5f3f..500a207 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -815,7 +815,7 @@ static int rlb_initialize(struct bonding *bond)
> =20
>  	/*initialize packet type*/
>  	pk_type->type =3D __constant_htons(ETH_P_ARP);
> -	pk_type->dev =3D bond->dev;
> +	pk_type->dev =3D NULL;
>  	pk_type->func =3D rlb_arp_recv;
> =20
>  	/* register to receive ARPs */

Hmm... I think the idea was good, but the whole system
crashes. To be correct, it simply reboots.

Any other suggestion for a quick test?!

Regards
 Sven

--=20
 Sven Anders <anders@anduras.de>                 () Ascii Ribbon Campaign=

                                                 /\ Support plain text e-=
mail
 ANDURAS service solutions AG
 Innstra=DFe 71 - 94036 Passau - Germany
 Web: www.anduras.de - Tel: +49 (0)851-4 90 50-0 - Fax: +49 (0)851-4 90 5=
0-55

Rechtsform: Aktiengesellschaft - Sitz: Passau - Amtsgericht Passau HRB 60=
32
Mitglieder des Vorstands: Sven Anders, Marcus Junker
Vorsitzender des Aufsichtsrats: Mark Peters

--------------090507080409070305020800
Content-Type: text/x-vcard; charset=utf-8;
 name="anders.vcf"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="anders.vcf"

begin:vcard
fn:Sven Anders
n:Anders;Sven
org:ANDURAS AG;Research and Development
adr;quoted-printable:;;Innstra=3DC3=3D9Fe 71;Passau;Bavaria;94036;Germany=

email;internet:anders@anduras.de
title:Dipl. Inf.
tel;work:++49 (0)851 / 490 50 -0
tel;fax:++49 (0)851 / 590 50 - 55
x-mozilla-html:FALSE
url:http://www.anduras.de
version:2.1
end:vcard


--------------090507080409070305020800--

--------------enigE7C019895E41A2B68DFDA772
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFI/jzl5lKZ7Feg4EcRAiykAJ4rBB3Ip/lTYRQBNNdKKuWy+jnCuwCeM3x5
pCmRv7tpaIJ15xOBWrHLiR8=
=PYI/
-----END PGP SIGNATURE-----

--------------enigE7C019895E41A2B68DFDA772--
