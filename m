From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the pm tree
Date: Wed, 26 Jun 2013 13:08:38 +1000
Message-ID: <20130626130838.fb1e8f7cbe232d231a036bf8@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__26_Jun_2013_13_08_38_+1000_W=OwMn=BqTw.AWqh"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Colin Cross <ccross@android.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__26_Jun_2013_13_08_38_+1000_W=OwMn=BqTw.AWqh
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
fs/select.c between commit 9745cdb36da8 ("select: use freezable blocking
call") from the pm tree and commit 2d48d67fa8cd ("net: poll/select low
latency socket support") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc fs/select.c
index 6b14dc7,79b876e..0000000
--- a/fs/select.c
+++ b/fs/select.c
@@@ -27,7 -27,7 +27,8 @@@
  #include <linux/rcupdate.h>
  #include <linux/hrtimer.h>
  #include <linux/sched/rt.h>
 +#include <linux/freezer.h>
+ #include <net/ll_poll.h>
 =20
  #include <asm/uaccess.h>
 =20

--Signature=_Wed__26_Jun_2013_13_08_38_+1000_W=OwMn=BqTw.AWqh
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRyls6AAoJEECxmPOUX5FEfPIQAJalg2SzCoWlxlPDsri8zgtU
KyN3SB3J5FVvxKJatyaXpKu/U0FmItceIFc0XFhEvPAk5gD2dZUi7lGs3i3oOn4O
SZ8AU/oR/WBT9NSB2DWbZfTb7VGJ8r7AzDE7F77KgeYZoUpgY8oyceZtUAssPFWO
7ZYvCcTPIoEUZF6M56PltLnKRUMnR0D2DIjevp7ynaeEKlmRPerNbDjT6zgYUhPd
pOF0SWusNxAP3LFfgoRFfZEnIb4EDIwMSCoA6uAy8+9Li55tbx2OP0FQB5xD9FHR
QJp+Eo2Rhpxi4pBVKsQXsPVb8Wnp4QdBvxJKB5nfxa6dkXrP3q480/1URlIZOS6y
EcTkN635uk2eGLk7fPx4g/Hc0431JH8XxPsGzoroSHOdS//WHsF3yfgMF+cTBn69
bBpOQiEYtlHn5EQebcSP+X6J4Eix2MqLC+rQqRGgy9V6oHa6zx/pmN58hkKwc4Ya
lmXQ4AMMXtXFk4FNfHkXqJOSN7CrE/ZOo5Fb2vJlu3juVDijL9kSRRP1D9GNg6Yb
czc9rOJ6HUvrRQEiUw/dPZnkm7KmQ37XhHUiJXhkQLLvfFMkZiPD+UWMs5wKug3x
XRwqjJf6kJoJj9swRD5bU/p5Kdg4rYBQdyJ1T2p4RZKQ7WgzbRU7VUKCRWiJP40H
y3+cFOL4Q5/ifNd61WhJ
=zIHJ
-----END PGP SIGNATURE-----

--Signature=_Wed__26_Jun_2013_13_08_38_+1000_W=OwMn=BqTw.AWqh--
