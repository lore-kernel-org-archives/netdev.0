From: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Subject: Please pull dscape-upsteam of bcm43xx driver
Date: Fri, 3 Feb 2006 21:03:32 +0100
Message-ID: <200602032103.32327.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1431826.JCBayrD56R";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <bcm43xx-dev-admin-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
To: "Linville, John W." <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
Errors-To: bcm43xx-dev-admin-tdrK/OAtAx2ELgA04lAiVw@public.gmane.org
List-Help: <mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Post: <mailto:bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Subscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
List-Unsubscribe: <http://lists.berlios.de/mailman/listinfo/bcm43xx-dev>,
	<mailto:bcm43xx-dev-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.berlios.de/pipermail/bcm43xx-dev/>
List-Id: netdev.vger.kernel.org

--nextPart1431826.JCBayrD56R
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Please do a
git pull git://bu3sch.de/wireless-2.6 dscape-upstream
to pull latest bcm43xx updates into dscape-all:

Michael Buesch:
      [bcm43xx] add DEBUG Kconfig option. Also fix indention.
      [bcm43xx] fix Kconfig "depends on" typo.
      [bcm43xx] Fix makefile. Remove all the "out-of-tree" stuff.
      [bcm43xx-d80211] Add more initvals sanity checks and error out, if on=
e sanity check fails.
      [bcm43xx] Add more initvals sanity checks and error out, if one sanit=
y check fails.
      [bcm43xx-d80211] [patch] basic ethtool support
      [bcm43xx-d80211] [patch] basic ethtool support (CONTINUED)
      [bcm43xx] Wireless Ext update:
      [bcm43xx-d80211] Add beacon template uploading code

 drivers/net/wireless/Kconfig                       |   19 ++
 drivers/net/wireless/bcm43xx-d80211/Makefile       |   87 +----------
 drivers/net/wireless/bcm43xx-d80211/bcm43xx.h      |   41 +----
 .../net/wireless/bcm43xx-d80211/bcm43xx_debugfs.c  |    8 +
 .../net/wireless/bcm43xx-d80211/bcm43xx_debugfs.h  |    6 -
 drivers/net/wireless/bcm43xx-d80211/bcm43xx_dma.c  |    8 +
 drivers/net/wireless/bcm43xx-d80211/bcm43xx_dma.h  |    4 -
 .../net/wireless/bcm43xx-d80211/bcm43xx_ethtool.c  |   50 +++++++
 .../net/wireless/bcm43xx-d80211/bcm43xx_ethtool.h  |    8 +
 drivers/net/wireless/bcm43xx-d80211/bcm43xx_main.c |  156 +++++++++++-----=
=2D---
 drivers/net/wireless/bcm43xx-d80211/bcm43xx_phy.c  |    6 -
 11 files changed, 196 insertions(+), 197 deletions(-)

=2D-=20
Greetings Michael.

--nextPart1431826.JCBayrD56R
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBD47cUlb09HEdWDKgRAg8zAJ9be2rTPiLzN0EIAc1vw4WuRgFk8QCfagU0
+w3WoeUXz6YN+oSU1UklG2Q=
=yEXZ
-----END PGP SIGNATURE-----

--nextPart1431826.JCBayrD56R--
