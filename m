From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: pull-request: can 2015-03-09
Date: Mon, 09 Mar 2015 10:45:49 +0100
Message-ID: <54FD6BCD.7080600@pengutronix.de>
References: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="3KmujoxnvkxRh4fRL2AIE6OxnHGHbTTrl"
Cc: davem@davemloft.net, kernel@pengutronix.de,
	linux-can@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--3KmujoxnvkxRh4fRL2AIE6OxnHGHbTTrl
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 03/09/2015 10:36 AM, Marc Kleine-Budde wrote:
> Hello David,

I've just noticed a typo in one of the subjects.

>> Marc Kleine-Budde (2):
>>       MAINTAINERS: linux-can moved to github
>>       MAINTAINERS: add Marc Kleine-Budde as co maintinaer for CAN netw=
orking layer
                                                  ^^^^^^^^^^

The series is updates, the tag re-created and I've force-pushed it to
the linux-can repo:

this is a pull request for net/master for the 4.0 release cycle, it consi=
sts of
6 patches:

A patch by Oliver Hartkopp fixes a long outstanding bug in the infrastruc=
ture,
which leads to skb_under_panics when CAN interfaces are used by AF_PACKET=

sockets e.g. by dhclient. Stephane Grosjean contributes a patch for the
peak_usb driver which adds a missing initialization. Two patches by Ahmed=
 S.
Darwish fix problems in the kvaser_usb driver. Followed by two patches by=

myself, updating the MAINTAINERS file.

Marc

---

The following changes since commit c247f0534cc5a5a547a343903f42295a471844=
e2:

  ip: fix error queue empty skb handling (2015-03-08 23:01:54 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/li=
nux-can-fixes-for-4.0-20150309

for you to fetch changes up to f7214cf29ca6c977ad2c428f2b832e9c66f2ee1b:

  MAINTAINERS: add Marc Kleine-Budde as co maintainer for CAN networking =
layer (2015-03-09 10:41:45 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.0-20150309

----------------------------------------------------------------
Ahmed S. Darwish (2):
      can: kvaser_usb: Avoid double free on URB submission failures
      can: kvaser_usb: Read all messages in a bulk-in URB buffer

Marc Kleine-Budde (2):
      MAINTAINERS: linux-can moved to github
      MAINTAINERS: add Marc Kleine-Budde as co maintainer for CAN network=
ing layer

Oliver Hartkopp (1):
      can: add missing initialisations in CAN related skbuffs

Stephane Grosjean (1):
      can: peak_usb: fix missing ctrlmode_ init for every dev

 MAINTAINERS                                |  5 ++--
 drivers/net/can/dev.c                      |  8 +++++
 drivers/net/can/usb/kvaser_usb.c           | 48 +++++++++++++++++++-----=
------
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c |  4 +++
 net/can/af_can.c                           |  3 ++
 5 files changed, 49 insertions(+), 19 deletions(-)

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--3KmujoxnvkxRh4fRL2AIE6OxnHGHbTTrl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCgAGBQJU/WvNAAoJECte4hHFiupU9nUP/3ftCiq3RpS1C+90xDrO3HZz
GlyCOcDOIXybPtS+QvyjzqIIG9d/C1TREbNgq3wCdzlpbCpKTrAv+bhnLU0JUGg4
V0keuaG7rqT/gcO8r8lUbyUX1SAY7WQE3uXuJUkk7BfQMGcI1JRNqsj6ycLVMt8+
GfixT1BJQ3RCkhbkraMABYAVXZa5B11slYTQW+QGLdra6vDto0dd3k4gpmVMHnCH
gFAArmapbpEWOsUC5tKOCQJuvU9c3d8bs7n4mg0SzztdxYy/mLm1DD1bjYZZ0cVL
UG0EU4aaZJHemDjNFGMfMAz7bLRrOElf7ES7qTcDmfsmuNEjZOQvDUacFRJlOeXG
tBdHv+B23LFHMRVQKKeui/ZgNJGJljvAfikQYcNt/PchJSF5RmvzMjPKrFmPgBU5
LV06ig89joG0ST5j6a1NyHlz5v5Il9+n4ztHCxJaKbcEskQ+cC2owH9H/DuZh4yZ
lxsybKKzglx9LwsUpWWUo9eMwgVHC85XE4hZdAhvbC5VtfSb+64HZu7MG66d2E/c
fZYKh+GgVv5ebszngHKWDpNuNaEnV3+4Oy1UqEeK7VQ1e8B1AR/oKti3wswhg1XM
oQvve+C6Fid2l7kc21vPLvM51E46iA3WTNWa+xOWjPbqWynHjghRRd+QLQMlbhSw
5I9tNinl8OtNhX+cmNTi
=KQgz
-----END PGP SIGNATURE-----

--3KmujoxnvkxRh4fRL2AIE6OxnHGHbTTrl--
