From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH] cdc-phonet: remove noisy debug statement
Date: Mon, 14 Sep 2009 16:10:28 +0300
Message-ID: <1252933829-12442-2-git-send-email-remi@remlab.net>
References: <1252933829-12442-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:57626 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276AbZINNK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 09:10:26 -0400
In-Reply-To: <1252933829-12442-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 drivers/net/usb/cdc-phonet.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.=
c
index 97e54d9..33d5c57 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -264,7 +264,6 @@ static int usbpn_ioctl(struct net_device *dev, stru=
ct ifreq *ifr, int cmd)
 	switch (cmd) {
 	case SIOCPNGAUTOCONF:
 		req->ifr_phonet_autoconf.device =3D PN_DEV_PC;
-		printk(KERN_CRIT"device is PN_DEV_PC\n");
 		return 0;
 	}
 	return -ENOIOCTLCMD;
--=20
1.6.0.4

