From: LIYONG <sdliyong@gmail.com>
Subject: [PATCH] cc2520: set the default fifo pin value from platform data
Date: Wed, 5 Aug 2015 15:39:46 +0800
Message-ID: <BLU168-W96900E039F7CBF326825DCD6750@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YONG LI <sdliyong@gmail.com>
To: "varkabhadram@gmail.com" <varkabhadram@gmail.com>,
	"alex.aring@gmail.com" <alex.aring@gmail.com>,
	"linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without the device tree support, the fifo_pin is uninitialized, this
Patch will set the fifo_pin value based on platform data

Signed-off-by: Yong Li <sdliyong@gmail.com>
---
=A0drivers/net/ieee802154/cc2520.c | 1 +
=A01 file changed, 1 insertion(+)

diff --git a/drivers/net/ieee802154/cc2520.c b/drivers/net/ieee802154/c=
c2520.c
index b6fc295..cd1e7ac 100644
--- a/drivers/net/ieee802154/cc2520.c
+++ b/drivers/net/ieee802154/cc2520.c
@@ -833,6 +833,7 @@ static int cc2520_get_platform_data(struct spi_devi=
ce *spi,
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!spi_pdata)
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -ENOENT;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *pdata =3D *spi_pdata;
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->fifo_pin =3D pdata->fifo;
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
=A0 =A0 =A0 =A0 }
