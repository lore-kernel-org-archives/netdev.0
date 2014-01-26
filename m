From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net/apne: Remove unused variable ei_local
Date: Sun, 26 Jan 2014 11:44:23 +0100
Message-ID: <1390733063-9077-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Matthew Whitehead <tedheadster@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/ethernet/8390/apne.c: In function =E2=80=98apne_probe1=E2=80=
=99:
drivers/net/ethernet/8390/apne.c:215: warning: unused variable =E2=80=98=
ei_local=E2=80=99

Introduced by commit c45f812f0280c13f1b7992be5e0de512312a9e8f ("8390 :
Replace ei_debug with msg_enable/NETIF_MSG_* feature"), which added the
variable without using it.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/8390/apne.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/8390/apne.c b/drivers/net/ethernet/83=
90/apne.c
index 811fa5d5c697..30104b60da85 100644
--- a/drivers/net/ethernet/8390/apne.c
+++ b/drivers/net/ethernet/8390/apne.c
@@ -212,7 +212,6 @@ static int __init apne_probe1(struct net_device *de=
v, int ioaddr)
     int neX000, ctron;
 #endif
     static unsigned version_printed;
-    struct ei_device *ei_local =3D netdev_priv(dev);
=20
     if ((apne_msg_enable & NETIF_MSG_DRV) && (version_printed++ =3D=3D=
 0))
 		netdev_info(dev, version);
--=20
1.7.9.5
