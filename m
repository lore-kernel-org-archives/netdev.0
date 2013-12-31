From: Pali =?utf-8?q?Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: Re: [PATCH v2 00/16] wl1251 patches from linux-n900 tree
Date: Tue, 31 Dec 2013 10:47:29 +0100
Message-ID: <201312311047.30147@pali>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com> <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart11973457.e5u0UglunI";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart11973457.e5u0UglunI
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable

On Sunday 08 December 2013 10:24:58 Pali Roh=C3=A1r wrote:
> Hello, I'm sending wl1251 patches from linux-n900 tree [1] for
> comments. More patches come from David's monitor & packet
> injection work. Patches are tested with 3.12 rc5 kernel on
> Nokia N900.
>=20
> Second version contains new patch for fixing NULL pointer
> dereference which sometimes cause kernel panic and fixes code
> suggested by Pavel Machek.
>=20
> [1] - https://gitorious.org/linux-n900/linux-n900
>=20
> David Gnedt (12):
>   wl1251: fix scan behaviour while not associated
>   wl1251: add sysfs interface for bluetooth coexistence mode
>     configuration
>   wl1251: retry power save entry
>   wl1251: implement hardware ARP filtering
>   wl1251: split RX and TX data path initialisation
>   wl1251: configure hardware en-/decryption for monitor mode
>   wl1251: implement multicast address filtering
>   wl1251: disable power saving in monitor mode
>   wl1251: fix channel switching in monitor mode
>   wl1251: enable tx path in monitor mode if necessary for
> packet injection
>   wl1251: disable retry and ACK policy for injected packets
>   wl1251: enforce changed hw encryption support on monitor
> state change
>=20
> Pali Roh=C3=A1r (4):
>   wl1251: add nvs file name to module firmware list
>   wl1251: Add sysfs file tx_mgmt_frm_rate for setting rate
>   wl1251: Add sysfs file address for setting permanent mac
> address wl1251: fix NULL pointer dereference
>=20
>  drivers/net/wireless/ti/wl1251/acx.c    |   92 +++++-
>  drivers/net/wireless/ti/wl1251/acx.h    |   34 ++-
>  drivers/net/wireless/ti/wl1251/boot.c   |    3 +-
>  drivers/net/wireless/ti/wl1251/cmd.c    |   59 +++-
>  drivers/net/wireless/ti/wl1251/cmd.h    |    8 +-
>  drivers/net/wireless/ti/wl1251/event.c  |   46 ++-
>  drivers/net/wireless/ti/wl1251/event.h  |    7 +
>  drivers/net/wireless/ti/wl1251/init.c   |   19 +-
>  drivers/net/wireless/ti/wl1251/main.c   |  462
> ++++++++++++++++++++++++++++++-
> drivers/net/wireless/ti/wl1251/rx.c     |    2 +-
>  drivers/net/wireless/ti/wl1251/tx.c     |   35 ++-
>  drivers/net/wireless/ti/wl1251/wl1251.h |   14 +
>  12 files changed, 720 insertions(+), 61 deletions(-)

So far, there are no new comments for patches 01, 03-13 and 16.=20
Are there any other problems with that patches or can be accepted=20
for upstream?

=2D-=20
Pali Roh=C3=A1r
pali.rohar@gmail.com


--nextPart11973457.e5u0UglunI
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iEYEABECAAYFAlLCkrIACgkQi/DJPQPkQ1KZHACeM3ejj0kRsjf2hqCJn5oeTdRo
UcUAnR7a4Bm4llmLe44GjGMT8FfmfzcJ
=qIiu
-----END PGP SIGNATURE-----

--nextPart11973457.e5u0UglunI--
