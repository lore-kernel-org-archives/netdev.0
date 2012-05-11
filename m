From: Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Subject: Re: pull request: bluetooth 2012-05-04
Date: Fri, 11 May 2012 17:16:20 -0300
Message-ID: <20120511201620.GD7620@joana>
References: <20120505001243.GC23728@joana>
 <20120508070211.GB11843@joana>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LZvS9be/3tNcYl/X"
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120508070211.GB11843@joana>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

I couldn't get this pull by John this week, he's been unresponsive.
We would love to see this code in the 3.4 kernel (not sure if this would be
possible if Linus do not release the -rc7, there are important fixes=20
in the pull request, such as a fix to a regression that was breaking blueto=
oth
keyboards.

Please let me know if you have any problems with this! I checked this code =
for
coding style issues too. Thanks.

	Gustavo

* Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org> [2012-05-08 04:07:54 -0300]:

> Hi John,
>=20
> * Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org> [2012-05-04 21:12:43 -0300]:
>=20
> > Hi John,
> >=20
> > A few more patch to 3.4. There is 3 fixes from Mat Martineau, a fix for
> > a incoming MTU check that was breaking ERTM, still on ERTM there is a
> > patch that fixes concurrency with one of our locks. His third patch is
> > related to lock fixes too.
> > Besides that Johan fixed a wrong bit set in the Inquiry code, Vishal
> > Agarwal added a EIR fix and finally we have support for one more usb id.
> >=20
> > Please pull or let me know of any problems!
>=20
> I saw that you didn't pull this yet, so I decided to re-do this pull requ=
est.
> We have more 3 important fixes to go in. They fix a regression that was
> preventing Bluetooth keyboard to work. I'll re-do the whole pull request
> message, so you can copy and paste it easily:
>=20
> A few more patch to 3.4. There is 3 fixes from Mat Martineau, a fix for a
> incoming MTU check that was breaking ERTM, still on ERTM there is a patch=
 that
> fixes concurrency with one of our locks. His third patch is related to lo=
ck
> fixes too.
> Besides that Johan fixed a wrong bit set in the Inquiry code, Vishal Agar=
wal
> added a EIR fix and finally we have support for one more usb id.  Finally
> Johan and I fixed a regression that was preventing bluetooth keyboard to =
work.
>=20
> Please pull or let me know of any problems!
>=20
> 	Gustavo
>=20
> ---
>=20
> The following changes since commit 985140369be1e886754d8ac0375dd64e4f7273=
11:
>=20
>   Add Foxconn / Hon Hai IDs for btusb module (2012-04-24 11:38:41 -0300)
>=20
> are available in the git repository at:
>=20
>   git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.git f=
or-upstream
>=20
> for you to fetch changes up to fbcb6a061652b38257a1d8bcf6ebd70fc1771549:
>=20
>   Bluetooth: mgmt: Fix device_connected sending order (2012-05-07 20:56:3=
0 +0300)
>=20
> ----------------------------------------------------------------
> Gustavo Padovan (2):
>       Bluetooth: notify userspace of security level change
>       Bluetooth: report the right security level in getsockopt
>=20
> Johan Hedberg (2):
>       Bluetooth: Fix Inquiry with RSSI event mask
>       Bluetooth: mgmt: Fix device_connected sending order
>=20
> Mat Martineau (3):
>       Bluetooth: Fix a redundant and problematic incoming MTU check
>       Bluetooth: Restore locking semantics when looking up L2CAP channels
>       Bluetooth: Lock the L2CAP channel when sending
>=20
> Michael Gruetzner (1):
>       bluetooth: Add support for Foxconn/Hon Hai AR5BBU22 0489:E03C
>=20
> Vishal Agarwal (1):
>       Bluetooth: Fix EIR data generation for mgmt_device_found
>=20
>  drivers/bluetooth/ath3k.c         |    6 ++++++
>  drivers/bluetooth/btusb.c         |    3 +++
>  include/net/bluetooth/bluetooth.h |    3 +--
>  include/net/bluetooth/hci_core.h  |   17 +++++++++++++++++
>  net/bluetooth/af_bluetooth.c      |    2 +-
>  net/bluetooth/hci_core.c          |    8 ++++++++
>  net/bluetooth/hci_event.c         |   17 +++++++++++++----
>  net/bluetooth/l2cap_core.c        |   35 ++++++++-----------------------=
----
>  net/bluetooth/l2cap_sock.c        |   39 +++++++++++++++++++++++++------=
--------
>  9 files changed, 82 insertions(+), 48 deletions(-)


--LZvS9be/3tNcYl/X
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJPrXOUAAoJEPs3PUX4s20o1V4P/i5hG0D3EojWsQDMVj19lnfa
3hNML4xwfZt5Mhj5INmsAkSkIW0vdr/eIhn//WFY/Y5LfTLVLHGHAIZKdwz7RiKi
S48jbCHK28Sx9b8En44Bd9SYR96UoFJum0b/XgoUE50lvFdDweG6/6xjVUftchCg
buu4RrtklfEx3QmAJXec9Cnn1chiZSn40Yiuok5z+rSVG8+GhWrkd9TyYkEKgZu2
DZ5wCgocNHJnnOwH9sTHsr1VX1azWoajtlEwzVc8PK13sBw68gRxSECT4fUy57HM
r8mDi1V+VY3OHVUMRQ7bExUzKJNKtX8+T5y/942OAnAImwrZo/pJ7zMO2BvOVfma
iJssDpqA6UKFPvd1ZHV9gw6aOq0QLfLQsRaSsnkT01o+bcRVqd6/GLgnle33VgC8
oT6jDs4T/dI3535QmPsROyh9AkD7vGfSpyc9nKwqA0KdIUPZcCGOzmboPKtfc8i2
+5hvksdXgHWqiBItal1qGXjyrZHqe3O7cV0+SQqxuNGu37PAoM1BXt87FuvNCyqj
tjXJbZn+zSeLt6qyIPcHImwxLW1s/cKe6G1e2IH4HXA/l12i2Z/phPC8dpSwK+xv
tu6ZdPY4WKG1rRuKoVGA5+8V+c0zo5aN57NTE50Xeo/p47Q6vhysqu9VHC7agkc+
mF6YIHsulo55ZWPpuOEb
=aVuD
-----END PGP SIGNATURE-----

--LZvS9be/3tNcYl/X--
