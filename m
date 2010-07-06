From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build warning after merge of the net tree
Date: Tue, 6 Jul 2010 14:25:42 +1000
Message-ID: <20100706142542.d723903f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__6_Jul_2010_14_25_42_+1000_1JvcP1rZUw03U4Ac"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__6_Jul_2010_14_25_42_+1000_1JvcP1rZUw03U4Ac
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

After merging the net tree, today's linux-next build (powerpc
ppc64_defconfig) produced these warnings:

drivers/scsi/sym53c8xx_2/sym_hipd.c: In function 'sym_print_msg':
drivers/scsi/sym53c8xx_2/sym_hipd.c:78: warning: zero-length gnu_printf for=
mat string
drivers/scsi/constants.c: In function 'scsi_print_sense':
drivers/scsi/constants.c:1407: warning: zero-length gnu_printf format string
drivers/scsi/constants.c:1413: warning: zero-length gnu_printf format string
drivers/scsi/constants.c: In function 'scsi_print_result':
drivers/scsi/constants.c:1456: warning: zero-length gnu_printf format string
drivers/scsi/sd.c: In function 'sd_print_sense_hdr':
drivers/scsi/sd.c:2599: warning: zero-length gnu_printf format string
drivers/scsi/sd.c:2601: warning: zero-length gnu_printf format string
drivers/scsi/sd.c: In function 'sd_print_result':
drivers/scsi/sd.c:2607: warning: zero-length gnu_printf format string

(There may be more ...)

Introduced by commit 99bcf217183e02ebae46373896fba7f12d588001 ("device.h
drivers/base/core.c Convert dev_<level> logging macros to functions").
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__6_Jul_2010_14_25_42_+1000_1JvcP1rZUw03U4Ac
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMMrBGAAoJEDMEi1NhKgbsRzYH/jaepTNeQmuFW+FzXr5hHYMy
QxdDHb08EVUC0/3MPefxIARoqPdF0CM4lXvkH0+20UXTCupyz8CvzqVIaYC5dSrk
7+lcCX7j6J//KtWqS9ojGBxy+2PWgMF5cj16vbH32R16G+t5yGaNdVT2KGfrA1H3
g5RHh0h5pPzV0Kb2PG2BG5/W0FqlCSmwwBHLwmu/auvmF7/sqLvQUH71pAEp8y2a
RPtX77cHXMzuLAlhC2d9Fxv4HWyiklyREWsFHQz9URpzPAouKsIb9DjfmDWVyHYB
NzXV0oUwLwwK1vgwh3+3UPBkb5rKkGSpWQJys6iAU/tFn5w1M4MbnNTL35JEX0E=
=bo2m
-----END PGP SIGNATURE-----

--Signature=_Tue__6_Jul_2010_14_25_42_+1000_1JvcP1rZUw03U4Ac--
