From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tty tree with the net-next tree
Date: Fri, 9 Mar 2012 17:02:01 +1100
Message-ID: <20120309170201.93eec7e1108165c02ba2311c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__9_Mar_2012_17_02_01_+1100_qdMZ3G.=3ir6u07Z"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Jiri Slaby <jslaby@suse.cz>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:53763 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135Ab2CIGCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 01:02:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__9_Mar_2012_17_02_01_+1100_qdMZ3G.=3ir6u07Z
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the tty tree got a conflict in
drivers/isdn/gigaset/interface.c between commit 5bd49735db39 ("gigaset:
Use semicolons to terminate statements") from the net-next tree and
commit 2f16669d322e ("TTY: remove re-assignments to tty_driver members")
from the tty tree.

I fixed it up (see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/isdn/gigaset/interface.c
index b826dac,8f8814a..0000000
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@@ -679,9 -593,8 +593,8 @@@ void gigaset_if_initdriver(struct gigas
  	if (tty =3D=3D NULL)
  		goto enomem;
 =20
- 	tty->magic =3D		TTY_DRIVER_MAGIC;
 -	tty->type =3D		TTY_DRIVER_TYPE_SERIAL,
 -	tty->subtype =3D		SERIAL_TYPE_NORMAL,
 +	tty->type =3D		TTY_DRIVER_TYPE_SERIAL;
 +	tty->subtype =3D		SERIAL_TYPE_NORMAL;
  	tty->flags =3D		TTY_DRIVER_REAL_RAW | TTY_DRIVER_DYNAMIC_DEV;
 =20
  	tty->driver_name =3D	procname;

--Signature=_Fri__9_Mar_2012_17_02_01_+1100_qdMZ3G.=3ir6u07Z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPWZzZAAoJEECxmPOUX5FErNMP/3+T+1zQ7refcekItmt/nfEq
h8MBwXsCMQxW77CkJZoNK6M18Ie3R1cYcyJ9XKaHRU12d//smZIqgkwHZhlfsNc7
wo6b4tKCLDHlds9O658hwCDG8ijlyqEX5IFLeS5Js/v5k4LUSCcWGogCl2ucNFlD
sJuhmOCshrmObgllNwZGNpNjrX3EeTtBYlKr7GqcmcNYScn1rN91srvhDhzJcqH5
1pMhS7eo1RoukSpM0Kl36KYArjF8CihzbXrhN033TRxy2wyBeVnUiJzonfufey9L
RQpHW1mWT7Y/nbgisTnnlRvYH+eaF3uVf5RuYwYOtbPlXZLIY0+k90qMlRSurcDW
vVuR/EdZm69b/RK/KM4jLaejH2kG1ZBJaLWsxQj+6ptfILSKi+p4nhSBi4LQJusM
+iqRwHCcRnV7BEPMeWRIsJXgkrCu0WaFAWLtoBUVkmSjjH3fCvQd9cvjEhwWg08R
fYwt5Pn0v2amZuluHdifSHFXKnSWPtrpXiRc9iLTPt2T9PJqIrrzW+Gc9OBS6/mt
Z0ctPHnOB3NhS/lhcHpGvxHZO3XwIQPXRgh9G9K579VKoo975yN6+SG6WfBXywGQ
QSXR38v10Gshh88u10C40SuLQk6ICsySdatHaD0e2UhZo9rpM1FsHbSzE/sE/gdz
+QHGxccNYEH07x4yEMRu
=MTsI
-----END PGP SIGNATURE-----

--Signature=_Fri__9_Mar_2012_17_02_01_+1100_qdMZ3G.=3ir6u07Z--
