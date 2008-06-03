From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 12/12]: wext: Emit event stream entries correctly when
	compat.
Date: Tue, 03 Jun 2008 22:48:49 +0200
Message-ID: <1212526129.14371.5.camel@johannes.berg>
References: <20080603.132856.202640855.davem@davemloft.net>
	 (sfid-20080603_224142_020184_AD8B761F)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-iCLrSeYeBZEIlTo979FJ"
Cc: linux-wireless@vger.kernel.org, linville@tuxdriver.com,
	mokuno@sm.sony.co.jp, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760343AbYFCUuO@vger.kernel.org>
In-Reply-To: <20080603.132856.202640855.davem@davemloft.net> (sfid-20080603_224142_020184_AD8B761F)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-iCLrSeYeBZEIlTo979FJ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Awesome stuff. With respect to wpa supplicant, I'd expect we need some
sort of handling for this wrt. notifications (multicast) which is a bit
awkward, but maybe wpa supplicant doesn't care too much.

> 4) The mechanical transformations to the drivers and wireless stack
>    bits to get the iw_request_info passed down into the routines
>    modified in #3.

>  drivers/net/wireless/airo.c                |   39 +++++---
>  drivers/net/wireless/atmel.c               |   24 ++++-
>  drivers/net/wireless/hostap/hostap.h       |    3 +-
>  drivers/net/wireless/hostap/hostap_ap.c    |   32 +++---
>  drivers/net/wireless/hostap/hostap_ioctl.c |   54 ++++++-----
>  drivers/net/wireless/libertas/scan.c       |   32 +++---
>  drivers/net/wireless/orinoco.c             |   19 ++--
>  drivers/net/wireless/prism54/isl_ioctl.c   |   45 +++++----
>  drivers/net/wireless/rndis_wlan.c          |   27 +++---
>  drivers/net/wireless/wl3501_cs.c           |   10 +-
>  drivers/net/wireless/zd1201.c              |   21 +++--
>  include/linux/wireless.h                   |   15 +++
>  include/net/iw_handler.h                   |  149 ++++++++--------------=
------
>  net/ieee80211/ieee80211_wx.c               |   44 +++++----
>  net/mac80211/ieee80211_i.h                 |    5 +-
>  net/mac80211/mlme.c                        |   43 +++++----
>  net/mac80211/wext.c                        |    2 +-

Did you miss drivers/net/ps3_gelic_wireless.c?

johannes

--=-iCLrSeYeBZEIlTo979FJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASEWuMKVg1VMiehFYAQKrAxAAttjlE+hV+qrBgC9bnfBTkunESHGr6SOx
ILKb88CbV67Plo7K2fmnbzpyPFer8HfgwQapktiFCP+I6rs5d+B859h0rxDmkwDc
y+bOnLpBoe6aBaC0nyWSFqqdMLWcMANDEiN+4yTq5zuAnUoKYieji+yEDMerKCBG
EF+FciW9hInz8bSNr644jcbFu2euZlpSXBOq20HVpPEWeECKWWJcrEtAxssgAw3J
L7WigkQRDbYHNGz9YdoCf5/hhInEYze8ZE/kUY+rn5EwVfE4eZmgf1s8Z7HiJMEJ
MecpxuIHUdN4VillcF7c2PrAcfIAghc0VVbPuTDRhwqX4hIzoRr8gprUCfU/hEwb
SVZUxtdcP9MUGtkuFxBH3CPBdxJRu5+em2hR7B4/1Z24bSTk2R9pQNdagxZnzgMb
KFFIZhOBaGcKBWYT+yU2+5e6K2VYr0XxH1+ORMFSfp+B0n5Z5TyGRKXBorBI1ItM
EZADRRdRx6dRV2aKRaVnj9grV08X96PYSZlZ6YpA6BMTUNk/MIdnu3bSVMHsi6/Z
y6Rt3ntx8kBWIYOxGgkWBglBX2t+zZjdWuh1PQ9nmuPkxPcLnrmeU0CMz2acUosn
dT2Gd2LYsFEtNMAcgzANWRfCN5i3cQgf4eIBri6vpaya/1gfqP6xumqaZjzo0LvA
uTU22SZhyHU=
=qeTW
-----END PGP SIGNATURE-----

--=-iCLrSeYeBZEIlTo979FJ--
