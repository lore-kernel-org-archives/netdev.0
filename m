From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH 0/3] vbus: venet macvlan rt netlink changes
Date: Mon, 01 Feb 2010 07:53:04 -0500
Message-ID: <4B66CEB0.2050806@gmail.com>
References: <20100114215058.4958.87746.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig01EC002098C79086720765C9"
Cc: alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, kaber@trash.net, arnd@arndb.de,
	netdev@vger.kernel.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100114215058.4958.87746.stgit@mimic.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig01EC002098C79086720765C9
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 1/14/10 4:52 PM, Patrick Mullaney wrote:
> (Applies to alacrityvm.git/master:a725f9950)
>=20
> This series changes the venet macvlan device such that it can
> be created via rt netlink and no longer requires any extensive
> changes to the macvlan device itself. The first patch removes
> prior changes to the macvlan device introduced in the alacrityvm
> tree and also implements the changes needed for creation and
> management via rt netlink. The subsequent patches(2 and 3) are
> changes to the macvlan device for GRO support and for type
> specific release. These 2 patches don't appear to be upstream.
> If desired and approved, I'll regenerate these last 2 for
> net-next.

Applied to alacrityvm.git/master.  Thanks Pat!

>=20
> ---
>=20
> Patrick Mullaney (3):
>       macvlan: use rtnl_link_ops->dellink during unregister notications=

>       macvlan: add GRO bit to features mask
>       venet-macvlan: allow rt netlink to create venet macvlan devices
>=20
>=20
>  drivers/net/macvlan.c                   |   72 ++----
>  include/linux/macvlan.h                 |    6 -
>  kernel/vbus/devices/venet/device.c      |    8 +
>  kernel/vbus/devices/venet/macvlan.c     |  360 ++++++++++++++++++++---=
--------
>  kernel/vbus/devices/venet/tap.c         |    3=20
>  kernel/vbus/devices/venet/venetdevice.h |    3=20
>  6 files changed, 265 insertions(+), 187 deletions(-)
>=20



--------------enig01EC002098C79086720765C9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAktmzrAACgkQP5K2CMvXmqGP0gCfd8f04M8xSxKJdQ5dSKexNR8b
kPIAn3E8C+rHpDEs15tNAhi5GHCx7Rwn
=oF+7
-----END PGP SIGNATURE-----

--------------enig01EC002098C79086720765C9--
