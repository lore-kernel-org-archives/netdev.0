From: Michael Buesch <mbuesch-KuiJ5kEpwI6ELgA04lAiVw@public.gmane.org>
Subject: Please pull softmac-upsteam of bcm43xx driver
Date: Fri, 3 Feb 2006 20:49:52 +0100
Message-ID: <200602032049.52583.mbuesch@freenet.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1444424.KxqtykkOVt";
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

--nextPart1444424.KxqtykkOVt
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Please do a
git pull git://bu3sch.de/wireless-2.6 softmac-upstream
to pull latest bcm43xx updates into softmac-all:

Michael Buesch:
      [bcm43xx] add DEBUG Kconfig option. Also fix indention.
      [bcm43xx] Fix makefile. Remove all the "out-of-tree" stuff.
      [bcm43xx] Add more initvals sanity checks and error out, if one sanit=
y check fails.
      [bcm43xx] Remove function bcm43xx_channel_is_allowed(). Geographical =
restriction should become part of the 80211 stack, so every driver does not=
 have to duplicate it.
      [bcm43xx] [patch] basic ethtool support
      [bcm43xx] Wireless Ext update:

 drivers/net/wireless/Kconfig                   |   19 +-
 drivers/net/wireless/bcm43xx/Makefile          |   88 ---------
 drivers/net/wireless/bcm43xx/bcm43xx.h         |    6 -
 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.c |    8 -
 drivers/net/wireless/bcm43xx/bcm43xx_ethtool.c |   50 +++++
 drivers/net/wireless/bcm43xx/bcm43xx_ethtool.h |    8 +
 drivers/net/wireless/bcm43xx/bcm43xx_main.c    |  241 +++++---------------=
=2D---
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c      |   12 +
 8 files changed, 144 insertions(+), 288 deletions(-)

=2D-=20
Greetings Michael.

--nextPart1444424.KxqtykkOVt
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBD47Pglb09HEdWDKgRAgLaAJ0Wi2WQTBDnq/3Sbr4fk6867okWvwCeMXcj
1yXg29wDkxgLGUmi/SP+qZA=
=o2Au
-----END PGP SIGNATURE-----

--nextPart1444424.KxqtykkOVt--
