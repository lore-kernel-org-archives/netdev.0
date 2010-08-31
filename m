From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Tue, 31 Aug 2010 12:57:38 +1000
Message-ID: <20100831125738.7f18610b.sfr@canb.auug.org.au>
References: <20100706142542.d723903f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__31_Aug_2010_12_57_38_+1000_VFySImY6pPgQK0F3"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	James Bottomley <James.Bottomley@suse.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:41844 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756678Ab0HaC5r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Aug 2010 22:57:47 -0400
In-Reply-To: <20100706142542.d723903f.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__31_Aug_2010_12_57_38_+1000_VFySImY6pPgQK0F3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Tue, 6 Jul 2010 14:25:42 +1000 Stephen Rothwell <sfr@canb.auug.org.au> w=
rote:
>
> After merging the net tree, today's linux-next build (powerpc
> ppc64_defconfig) produced these warnings:
>=20
> drivers/scsi/sym53c8xx_2/sym_hipd.c: In function 'sym_print_msg':
> drivers/scsi/sym53c8xx_2/sym_hipd.c:78: warning: zero-length gnu_printf f=
ormat string
> drivers/scsi/constants.c: In function 'scsi_print_sense':
> drivers/scsi/constants.c:1407: warning: zero-length gnu_printf format str=
ing
> drivers/scsi/constants.c:1413: warning: zero-length gnu_printf format str=
ing
> drivers/scsi/constants.c: In function 'scsi_print_result':
> drivers/scsi/constants.c:1456: warning: zero-length gnu_printf format str=
ing
> drivers/scsi/sd.c: In function 'sd_print_sense_hdr':
> drivers/scsi/sd.c:2599: warning: zero-length gnu_printf format string
> drivers/scsi/sd.c:2601: warning: zero-length gnu_printf format string
> drivers/scsi/sd.c: In function 'sd_print_result':
> drivers/scsi/sd.c:2607: warning: zero-length gnu_printf format string
>=20
> (There may be more ...)
>=20
> Introduced by commit 99bcf217183e02ebae46373896fba7f12d588001 ("device.h
> drivers/base/core.c Convert dev_<level> logging macros to functions").

Can we have a fix for these please?  They make too much noise in the builds.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__31_Aug_2010_12_57_38_+1000_VFySImY6pPgQK0F3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMfG+iAAoJEDMEi1NhKgbsztMH/2AQV1CSd2cAYQypxMqZgZ9D
JAmIw387jJwnn45mWnVhkLUQPlrm0tmGPkefjMpx9yOCegFl3KEmh4CnJkrUlhS3
BDvep+VM8ufLs4sSdcCLP/Bd+JE8XbiHEvRBV8tyHaEJ1Wj6CfQ3BHjavWZbG/pU
JGuTbZTjkP1JTYWQolIdzZWoC8Hc+xAHzM6QOl06dpdjTDJwTeWy1oIp75WwLL4t
g9NCz6gN3X2fCqpfZlT2v40PG3dOCx66sOYCjktpOrPCgH8rQYPXqrUgkQ2C6RH/
rek6UabL2H7eUJI8cqid3onKFweVTITH+6AQyW1ojZ4/hZPVpk3po0UCB5ZofW4=
=TydS
-----END PGP SIGNATURE-----

--Signature=_Tue__31_Aug_2010_12_57_38_+1000_VFySImY6pPgQK0F3--
