From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: pull request: wireless 2013-01-09
Date: Wed, 9 Jan 2013 14:53:32 -0500
Message-ID: <20130109195332.GC17321@tuxdriver.com>
References: <20130109191817.GA17321@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="uAKRQypu60I7Lcqm"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41952 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932511Ab3AIUAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2013 15:00:14 -0500
Content-Disposition: inline
In-Reply-To: <20130109191817.GA17321@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--uAKRQypu60I7Lcqm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Ooops!  Forgot to sign it...

On Wed, Jan 09, 2013 at 02:18:18PM -0500, John W. Linville wrote:
> Dave,
>=20
> Please pull this batch of fixes (and a new driver) for the 3.8 stream...
>=20
> Included is a mac80211 pull, of which Johannes says the following:
>=20
> 'This includes a number of fixes for various pieces of mac80211. I've
> also included Thomas's memory RMC hash table optimisation since it
> saves so much memory.'
>=20
> Also from Johannes is an iwlwifi pull:
>=20
> 'I have two fixes for iwlwifi: one to fix a lost return value that was
> dropped in a previous patch and could cause "nobody cared" IRQ messages,
> and one to work around a firmware issue.'
>=20
> Amitkumar Karwar brings an mwifiex for a typo in an comparison.
>=20
> Bing Zhao gives us an mwifiex fix to properly check the return value
> from wait_event_interruptible and handle it properly.
>=20
> Chen Gang provides a fix to make iwlegacy use strlcpy instead of
> strncpy, avoiding a potential buffer underflow.
>=20
> Julian Wollrath fixes a typo in an error message in rtlwifi.
>=20
> Larry Finger brings a b43 fix for a firmware loading problem.
>=20
> Nickolai Zeldovich avoids a use-after-free in the mwl8k driver.
>=20
> Vladimir Kondratiev brings the last big piece, the new Qualcomm/Atheros
> wil6210 802.11ad driver.  Since it is for new hardware, I hope that
> taking it for 3.8 is not a problem.
>=20
> Please let me know if there are problems!
>=20
> Thanks,
>=20
> John
>=20
> ---
>=20
> The following changes since commit c9be4a5c49cf51cc70a993f004c5bb30067a65=
ce:
>=20
>   net: prevent setting ttl=3D0 via IP_TTL (2013-01-08 17:57:10 -0800)
>=20
> are available in the git repository at:
>=20
>   git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for=
-davem
>=20
> for you to fetch changes up to a9b8a894ad7d0b90b0464c9ac7e8e5c1687edcae:
>=20
>   Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/=
linville/wireless into for-davem (2013-01-09 11:01:37 -0500)
>=20
> ----------------------------------------------------------------
>=20
> Amitkumar Karwar (1):
>       mwifiex: fix typo in setting up ibss network parameters
>=20
> Bing Zhao (1):
>       mwifiex: check wait_event_interruptible return value
>=20
> Chaitanya (1):
>       mac80211: fix maximum MTU
>=20
> Chen Gang (1):
>       drivers/net/wireless/iwlegacy: use strlcpy instead of strncpy
>=20
> Emmanuel Grumbach (1):
>       iwlwifi: fix the reclaimed packet tracking upon flush queue
>=20
> Felix Fietkau (1):
>       mac80211: flush AP_VLAN stations when tearing down the BSS AP
>=20
> Johannes Berg (5):
>       mac80211: assign VLAN channel contexts
>       mac80211: fix station destruction in AP/mesh modes
>       mac80211: use del_timer_sync for final sta cleanup timer deletion
>       mac80211: fix dtim_period in hidden SSID AP association
>       iwlwifi: fix PCIe interrupt handle return value
>=20
> John W. Linville (3):
>       Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
>       Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi=
-fixes
>       Merge branch 'master' of git://git.kernel.org/.../linville/wireless=
 into for-davem
>=20
> Julian Wollrath (1):
>       rtlwifi: Fix typo in debug output of rtl8192c and rtl8723ae
>=20
> Larry Finger (1):
>       b43: Fix firmware loading when driver is built into the kernel
>=20
> Nickolai Zeldovich (1):
>       drivers/net/wireless/mwl8k.c: avoid use-after-free
>=20
> Stanislaw Gruszka (1):
>       mac80211: fix ibss scanning
>=20
> Thomas Pedersen (1):
>       mac80211: RMC buckets are just list heads
>=20
> Vladimir Kondratiev (1):
>       wireless: add new wil6210 802.11ad 60GHz driver
>=20
>  MAINTAINERS                                        |    8 +
>  drivers/net/wireless/ath/Kconfig                   |    1 +
>  drivers/net/wireless/ath/Makefile                  |    1 +
>  drivers/net/wireless/ath/wil6210/Kconfig           |   29 +
>  drivers/net/wireless/ath/wil6210/Makefile          |   13 +
>  drivers/net/wireless/ath/wil6210/cfg80211.c        |  573 ++++++++++
>  drivers/net/wireless/ath/wil6210/dbg_hexdump.h     |   30 +
>  drivers/net/wireless/ath/wil6210/debugfs.c         |  603 +++++++++++
>  drivers/net/wireless/ath/wil6210/interrupt.c       |  471 +++++++++
>  drivers/net/wireless/ath/wil6210/main.c            |  407 +++++++
>  drivers/net/wireless/ath/wil6210/netdev.c          |  157 +++
>  drivers/net/wireless/ath/wil6210/pcie_bus.c        |  223 ++++
>  drivers/net/wireless/ath/wil6210/txrx.c            |  871 +++++++++++++++
>  drivers/net/wireless/ath/wil6210/txrx.h            |  362 +++++++
>  drivers/net/wireless/ath/wil6210/wil6210.h         |  363 +++++++
>  drivers/net/wireless/ath/wil6210/wmi.c             |  975 ++++++++++++++=
+++
>  drivers/net/wireless/ath/wil6210/wmi.h             | 1116 ++++++++++++++=
++++++
>  drivers/net/wireless/b43/b43.h                     |    5 +
>  drivers/net/wireless/b43/main.c                    |   54 +-
>  drivers/net/wireless/b43/main.h                    |    5 +-
>  drivers/net/wireless/iwlegacy/3945-mac.c           |    2 +-
>  drivers/net/wireless/iwlwifi/dvm/tx.c              |   24 +-
>  drivers/net/wireless/iwlwifi/pcie/rx.c             |    1 +
>  drivers/net/wireless/mwifiex/cfg80211.c            |    2 +-
>  drivers/net/wireless/mwifiex/sta_ioctl.c           |   21 +-
>  drivers/net/wireless/mwl8k.c                       |    4 +-
>  drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |    2 +-
>  drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       |    2 +-
>  net/mac80211/cfg.c                                 |    2 +
>  net/mac80211/chan.c                                |   38 +
>  net/mac80211/ibss.c                                |    9 +-
>  net/mac80211/ieee80211_i.h                         |   16 +-
>  net/mac80211/iface.c                               |   48 +-
>  net/mac80211/mesh.c                                |    8 +-
>  net/mac80211/mesh.h                                |    2 +-
>  net/mac80211/mlme.c                                |   75 +-
>  net/mac80211/scan.c                                |   46 +-
>  net/mac80211/sta_info.c                            |   46 +-
>  net/mac80211/sta_info.h                            |    3 +-
>  39 files changed, 6488 insertions(+), 130 deletions(-)
>  create mode 100644 drivers/net/wireless/ath/wil6210/Kconfig
>  create mode 100644 drivers/net/wireless/ath/wil6210/Makefile
>  create mode 100644 drivers/net/wireless/ath/wil6210/cfg80211.c
>  create mode 100644 drivers/net/wireless/ath/wil6210/dbg_hexdump.h
>  create mode 100644 drivers/net/wireless/ath/wil6210/debugfs.c
>  create mode 100644 drivers/net/wireless/ath/wil6210/interrupt.c
>  create mode 100644 drivers/net/wireless/ath/wil6210/main.c
>  create mode 100644 drivers/net/wireless/ath/wil6210/netdev.c
>  create mode 100644 drivers/net/wireless/ath/wil6210/pcie_bus.c
>  create mode 100644 drivers/net/wireless/ath/wil6210/txrx.c
>  create mode 100644 drivers/net/wireless/ath/wil6210/txrx.h
>  create mode 100644 drivers/net/wireless/ath/wil6210/wil6210.h
>  create mode 100644 drivers/net/wireless/ath/wil6210/wmi.c
>  create mode 100644 drivers/net/wireless/ath/wil6210/wmi.h
> --=20
> John W. Linville		Someday the world will need a hero, and you
> linville@tuxdriver.com			might be all we have.  Be ready.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--uAKRQypu60I7Lcqm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ7cq8AAoJEJctW/TcYTgGxiUP/2ljnyTYKJ6iU35DJU9wr0As
55u3Lx0UBQ4VCjlVmikJcDNm2BGMnaTUUV3XRaxdHXdTR5kI5ExiPkvbLUWQowGs
TgG6pZNfat12J9b0JSlA6td+qwN5zLsWPLE8me8jTU2cl5q1BVntKmUOLhJrgx50
Gxv2FkwWbIMm+y93FmNCNehLEwBROAtvP7H83sAzyeSceICsuTjrXqvaS2EJPp54
wUqSgmjAhHLJDwlokPsiptOPJqqcvsR4xlrWqARCcSm8gJojjj1V91qfkFGPseI8
7F3QLhbbnAhf99etQcLj3gSRUUgp69BfCJIhzVmgwsdqEGA4nkx+zwEpmHL247h9
/RCh+KgMn/RV6GlMc+LT8LjIC0mvsC3LsiSfOPFpBwMuM5tlWPQH1Fq77eNeo0ha
O8BTdL57BBjEXwB1eUpBJV/x3uMlVlOpYxOWmsLqRg8B7uYLDN4XpZ+Chi0kV+eI
6k3qIYhgbgg6pkkd4JXG/pqjgm1wrLSJF8ppa4kDvnmi/F80oYTZdHKDp75ZFwKh
ADtqRgDOpfUetFsJ0bdp0zGp6I7WYxa68j5vPvIbEMhFD32mHInKSq9QrLntaUXr
rzM4v9lg5K6OEALl5v8Op1Z2fJNMoyyHCCNRtyLVwQIn2a2JNWYFK+PcO3mqOlsw
0PHfYvaExVpQ1fJMy/Vv
=0YJK
-----END PGP SIGNATURE-----

--uAKRQypu60I7Lcqm--
