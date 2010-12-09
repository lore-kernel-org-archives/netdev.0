From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Thu, 9 Dec 2010 13:28:36 +1100
Message-ID: <20101209132836.6f6acfb8.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__9_Dec_2010_13_28_36_+1100_bmZIZ7Jhhn313u.z"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Oliver Hartkopp <socketcan@hartkopp.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__9_Dec_2010_13_28_36_+1100_bmZIZ7Jhhn313u.z
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

drivers/net/can/slcan.c: In function 'slcan_open':
drivers/net/can/slcan.c:568: error: dereferencing pointer to incomplete type

Caused by commit a1044e36e457fb6dbdf90ce756d578b251d99b5e ("can: add
slcan driver for serial/USB-serial CAN adapters").

I have used the net tree from next-20101208 for today.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__9_Dec_2010_13_28_36_+1100_bmZIZ7Jhhn313u.z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNAD7UAAoJEDMEi1NhKgbs+3IH/31QM+5BxzK6PBjlfv8oGflv
n7dzMxKIuFm2GjmdycMyYnI5RNv93elUU3nBgqUr+HMQWGyh+G/IKTmbLE8Z0YVN
UJtOxwObJhDGiNRx8upKSzMOtNc7Z1bSSuNmdKXQxTkosk2kiRLq9JaBBvKWwlF4
u73cwweDa5CmE9nha9GtjUGdi3dleVyurU/UOaM4im/YQf4bdptA2d8mDLNiPm3d
g8YDykZtE3PYKl4DLKEdlXhTUe5rOs/XobXQTBbIhI6CxB3W9huhOsuWtkuQrPQA
5krXxhCUWFOvXmQnUI8piZ7PByJRaKwBVxi/OAPozhbSlh+2OD7OzY+zYHBll5o=
=sKqE
-----END PGP SIGNATURE-----

--Signature=_Thu__9_Dec_2010_13_28_36_+1100_bmZIZ7Jhhn313u.z--
