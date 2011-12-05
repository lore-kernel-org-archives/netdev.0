From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2011-12-05
Date: Mon, 5 Dec 2011 12:19:39 -0500
Message-ID: <20111205171938.GD2531@tuxdriver.com>
References: <20111205163032.GC2531@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1yeeQ81UyVL57Vl7"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111205163032.GC2531@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--1yeeQ81UyVL57Vl7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Forgot the signature...I'll sign this one, just in case! :-)

John

On Mon, Dec 05, 2011 at 11:30:32AM -0500, John W. Linville wrote:
> commit cbec0627ef1adf7afa448e8bbae3146ce910212a
>=20
> Dave,
>=20
> This batch of fixes is intended for 3.2.
>=20
> Included is an iwlwifi fix to correctly set some flags related to packet
> encryption, a couple of cfg80211 regulatory fixes (including one that
> patches a hole created by the earlier "cfg80211: fix regulatory NULL
> dereference"), a mac80211 fix to avoid sending probe requests with no
> supported rates included, an iwlwifi fix to prevent reconfiguring HT40
> after an association (prevents an assert in the firmware), and another
> iwlwifi fix that customizes the watchdog timer enablement based on the
> device type.
>=20
> Also included is a reversion of a patch that was causing the iwlegacy
> driver to throw WARNINGs.
>=20
> Please let me know if there are problems!
>=20
> John
>=20
> ---
>=20
> The following changes since commit f61759e6b831a55b89e584b198c3da325e2bc3=
79:
>=20
>   ipv4: make sure RTO_ONLINK is saved in routing cache (2011-12-03 01:32:=
23 -0500)
>=20
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for=
-davem
>=20
> Johannes Berg (1):
>       iwlagn: fix HW crypto for TX-only keys
>=20
> John W. Linville (2):
>       Revert "mac80211: clear sta.drv_priv on reconfiguration"
>       Merge branch 'master' of git://git.kernel.org/.../linville/wireless=
 into for-davem
>=20
> Luis R. Rodriguez (2):
>       cfg80211: fix race on init and driver registration
>       cfg80211: amend regulatory NULL dereference fix
>=20
> Simon Wunderlich (1):
>       mac80211: fill rate filter for internal scan requests
>=20
> Wey-Yi Guy (2):
>       iwlwifi: do not re-configure HT40 after associated
>       iwlwifi: change the default behavior of watchdog timer
>=20
>  drivers/net/wireless/iwlwifi/iwl-1000.c     |    1 +
>  drivers/net/wireless/iwlwifi/iwl-5000.c     |    1 +
>  drivers/net/wireless/iwlwifi/iwl-agn-rxon.c |   36 ++++++++++++-------
>  drivers/net/wireless/iwlwifi/iwl-agn-sta.c  |    5 ---
>  drivers/net/wireless/iwlwifi/iwl-agn.c      |   34 +++++++++---------
>  drivers/net/wireless/iwlwifi/iwl-agn.h      |    2 +
>  drivers/net/wireless/iwlwifi/iwl-core.c     |   22 +++++++++---
>  drivers/net/wireless/iwlwifi/iwl-core.h     |    2 +
>  drivers/net/wireless/iwlwifi/iwl-shared.h   |    4 +-
>  net/mac80211/main.c                         |    6 +++
>  net/mac80211/util.c                         |    1 -
>  net/wireless/reg.c                          |   49 +++++++++++++++++----=
------
>  12 files changed, 102 insertions(+), 61 deletions(-)

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--1yeeQ81UyVL57Vl7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJO3P0qAAoJEJctW/TcYTgGv1EP/2OP9nSnOM6jBvI4Fn20LhEu
i+JiUintd1GjaKTxLUw7DFqopk5l6JsSZnATiKwv9+3dy/wyb6aJ5re0lwVidRX/
jPbkwxZJBh/uAjkkOPDSzD150KO4CwerrPm5BqW3pXzI4mGd6kg2exaOtfwWVC9s
A/kf9QiyTWm6c3sFnocsItkUUDIlraA3c8n5pRH7nLGB95fmA1bMVHimRRWa/qrj
JBmjq0B5sSnMJzjbjA7Pyfo8tj5vPFBoXNKLjG+iX5O/Hz5j9XmSyYhZGYEtQhWs
CceLEFaCXzYT8JbVaDtLdSKGgm+JbDSH/6pe67q7Kp/mnbh3fmjcqsn0tOmpZ4qG
Q34aUMkb+beKlJTELstYSidBXkJSJRht7vb9A9wG+v0//giD5uAClJS64ZFZLrcZ
eDbrxQ8RkcBQdaDX/myW+R0ZVnDdc5vcdl9+mwILW1fguJsD+6obNNqKu/PXldXg
z/YaTaZQfXNDTsRR2C6qdExUcBIAwS35baV8WT/GRsgtwO+qiCjjLNURhvN5K4TM
/qNbf+od8O0Lm2V56QvQmQbZsToSIYHli8lTFz0yiHEcoy77+MTfWkc2Rk0ivLWR
lb2gg0brlu5b1cMe8tG8C1y9z5dyEKI5MVZGspKIkjEIQl0lxgBA4CFu5wceGmdu
RpuCqydwFHgXbtGukOAq
=DPJD
-----END PGP SIGNATURE-----

--1yeeQ81UyVL57Vl7--
