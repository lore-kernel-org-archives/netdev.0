From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2014-05-08
Date: Thu, 8 May 2014 11:25:17 -0400
Message-ID: <20140508152516.GC6180@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="x+6KMIRAuhnl3hBn"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--x+6KMIRAuhnl3hBn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

This one is all from Johannes:

"Here are a few small fixes for the current cycle: radiotap TX flags were
wrong (fix by Bob), Chun-Yeow fixes an SMPS issue with mesh interfaces,
Eliad fixes a locking bug and a cfg80211 state problem and finally
Henning sent me a fix for IBSS rate information."

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 23a456f05353035d1a2b3f1b9a92707acdc036e0:

  net: mdio: of_mdiobus_register(): fall back to mdiobus_register() for !CO=
NFIG_OF (2014-05-07 17:16:35 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 6153871f77f8fa778cd0cf1e2979db75e25d3532:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-05-08 11:13:41 -0400)

----------------------------------------------------------------

Bob Copeland (1):
      mac80211: fixup radiotap tx flags for RTS/CTS

Chun-Yeow Yeoh (1):
      mac80211: avoid handling of SMPS for mesh

Eliad Peller (3):
      cfg80211: free sme on connection failures
      cfg80211: add cfg80211_sched_scan_stopped_rtnl
      mac80211: fix nested rtnl locking on ieee80211_reconfig

Henning Rogge (1):
      mac80211: Fix mac80211 station info rx bitrate for IBSS mode

John W. Linville (2):
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

 include/net/cfg80211.h  | 12 ++++++++++++
 net/mac80211/rx.c       |  3 ++-
 net/mac80211/sta_info.c |  3 ++-
 net/mac80211/status.c   |  5 ++---
 net/mac80211/util.c     |  2 +-
 net/wireless/scan.c     | 12 ++++++++++--
 net/wireless/sme.c      |  2 +-
 7 files changed, 30 insertions(+), 9 deletions(-)
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--x+6KMIRAuhnl3hBn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTa6HcAAoJEJctW/TcYTgG3j4P/iB4YQnvff21FL96dLDTIHc0
Jdv9EtU10bM2gII5U+X4YElSK34Kdrb3u9CkxM/AcqBu3BBB0AR7fuuPUqfflaGl
xgE2DhqQDNa/KwDyZgqw3LQCnicd9s/RoiIDJqaCxQ6vnau23IKKN0Wx8zGTEwbA
C3Mo3hz3xroGfqM1CM4x3J1GtZ+BczTW1oGTOYnGBeoIPoRV4qrPDjzL6Od28g/p
r+p6ZeJXTzpNdekxZiL1LU16MIWSC8cB873K76KxOhmLaBFziK7td4So/Mek+9Yh
qYJRvR2GcdPrpKUWs/vc8sZw5t7gyxR6pwVBgnyDsUX87vvbVl8y+swIgZtmpi2f
PO9NKuNEs/3OKneOVzMpoD3oGd8l1UywpmJiagYQZ70CSWpSZX+JHEJRPCg3Rn0F
PsJ0tgPViF2wTs1J9jq/8hCrp6qI+eCNdVVbBVtXPNuk3ZMceIom6Cg0tUQsJJ1X
GEgi2aT21gXBtCddQIB6y7VbQGOh4ubXrU2WW+WudbStrh96U4LuClXurFAzfhe+
dQGs6MtoHfaM0HnVCRLqc78taUCBBtezAni5GH0T4wHGzBBLjxo6Xqgrz8z+c5C7
ykI+JmioMCpj7ar74Tk16tfNntx+tHf2dXYcLf6NCwHExkoGnMpnyk5DHxUGtX8i
LHeKYS3WoK/dgc5DzdMW
=JMaa
-----END PGP SIGNATURE-----

--x+6KMIRAuhnl3hBn--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
