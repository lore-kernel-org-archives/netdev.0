From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-04-19
Date: Fri, 19 Apr 2013 10:35:51 -0400
Message-ID: <20130419143550.GB2925@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="YiEDa0DAkWCtVeE4"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sapphire.tuxdriver.com ([70.61.120.61]:35273 "EHLO
	linville-x1.hq.tuxdriver.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1030552Ab3DSOgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 10:36:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

A few stragglers hoping for 3.9, somewhat delayed due to my travels...

On the mac80211 bits, Johannes says:

"Sadly, I have another pull request -- the idle handling fix broke LED
handling in some cases."

and:

"Yet one more!

This fixes a fairly important/annoying bug -- when roaming between
multiple APs of the same network, the system could get stuck thinking it
was connected to the old one while it really wasn't."

On top of that...

Arend sends a brcmfmac patch that removes advertising a feature that
isn't actually fully supported, and a brcmsmac patch that rearranges
code to request firmware at IFF_UP to play more nicely with being
built into the kernel.

Felix gives us a minor ath9k_htc fix to support the newly released
open source firmware, and an ath9k_hw initvals fix to improve device
stability.

Rafa=C5=82 Mi=C5=82ecki provides a fix for an ssb regression that caused a
serious performance problem with b43.

Zefir Kurtisi offers an ath9k fix to change some kmalloc flags to
allow the DFS detector to be called in softirq context.

Please let me know if there are problems.  If these don't make 3.9,
I'll just pull them into wireless-next -- just let me know if you
want to do it that way!

John

---

The following changes since commit ea2f2fa143ead1a9bf5ce87a3abe403694fe6d78:

  Merge branch 'fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/jes=
se/openvswitch (2013-04-18 00:20:57 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 5a22483e5a2109cf678580d2bf769b0e69966a24:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-04-18 15:01:30 -0400)

----------------------------------------------------------------

Arend van Spriel (2):
      brcmfmac: remove advertising P2P device support
      brcmsmac: request firmware in .start() callback

Felix Fietkau (2):
      ath9k_htc: accept 1.x firmware newer than 1.3
      ath9k_hw: change AR9580 initvals to fix a stability issue

Johannes Berg (2):
      mac80211: fix LED in idle handling
      mac80211: fix cfg80211 interaction on auth/assoc request

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://x-git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Rafa=C5=82 Mi=C5=82ecki (1):
      ssb: implement spurious tone avoidance

Zefir Kurtisi (1):
      ath9k: fix DFS detector called in softirq context

 .../net/wireless/ath/ath9k/ar9580_1p0_initvals.h   |   2 +-
 .../net/wireless/ath/ath9k/dfs_pattern_detector.c  |   4 +-
 drivers/net/wireless/ath/ath9k/dfs_pri_detector.c  |   4 +-
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |   2 +-
 drivers/net/wireless/b43/phy_n.c                   |   3 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   7 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  | 264 ++++++++++-------=
----
 drivers/ssb/driver_chipcommon_pmu.c                |  29 +++
 include/linux/ssb/ssb_driver_chipcommon.h          |   2 +
 net/mac80211/iface.c                               |  27 ++-
 net/mac80211/mlme.c                                |  24 +-
 11 files changed, 211 insertions(+), 157 deletions(-)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--YiEDa0DAkWCtVeE4
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRcVZGAAoJEJctW/TcYTgGHuoQAJSt45tk3PeUt+33jKxBlJEz
Ju7hZ+W6PYOgoGuqADpZUsGEqYRTnBNIwc/BJtkrHJpSO0j+k3nAo0fUfT7x9T83
QwbDKas7C7w/VPtJ5V12EpelaFptH9Sl+8EeS2QcYRDC16Y1qupk2QV5xfKvrljN
b0n4Dw0u3YG8TC3R3l0tYMlESxr6h3jkHElo0boiK7l0kV3Al+7vjPm2ciDrXcOy
DjETJnHkP4dDz1vRKuHDuPv4CutveLv/8ErTp/jTT6apRTSE51qnyQvtmM4U0c3Z
RQGeWvCB6qWUak1EiyMOLTRIplvYtmCuaNlExzeQJ/7WD9bo4a7ztV8LNKsjr6NY
lbR/02CFT5pgSRv1YrPdLqn6Hcvh9UJgo4UlrgQbXfdFbmScMG2TUrtDgCgccLRQ
7DXdhcQevvg7U+b9TKHhdFKSlExsZU8kxy96VYfJL2etkQZNnlusJWR5sYRNKY1D
2xE5H/VjeXQVCXMjRPXaQwBuGi1nefUQeNAZpvVzZ98D0zYLNfQPflKDEYBNqCBQ
AKnhEGlvynzbZOrbs+GjIGCFHOiMi92nLfQ3dG17NWTRMyWg+qnZrbO5SpUvOhHL
B24OdbM6QQpNeriFbNHWW+ci8ie0mqAj97qU76cUJv/ugi16Y/S8Dw4gJJ/813VF
2xeiC6NWSxPC2Gpm1kg6
=/nR7
-----END PGP SIGNATURE-----

--YiEDa0DAkWCtVeE4--
