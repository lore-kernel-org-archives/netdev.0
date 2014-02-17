From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] USB2NET : SR9800 : Use %zu to format size_t
Date: Mon, 17 Feb 2014 22:18:39 +0100
Message-ID: <1392671920-11489-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Liu Junliang <liujunliang_ljl@163.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 32-bit:

drivers/md/bcache/bset.c: In function =E2=80=98bch_dump_bset=E2=80=99:
drivers/md/bcache/bset.c:27: warning: format =E2=80=98%li=E2=80=99 expe=
cts type =E2=80=98long int=E2=80=99, but argument 3 has type =E2=80=98i=
nt=E2=80=99

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/usb/sr9800.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
index 4175eb9fdeca..801710883727 100644
--- a/drivers/net/usb/sr9800.c
+++ b/drivers/net/usb/sr9800.c
@@ -823,7 +823,7 @@ static int sr9800_bind(struct usbnet *dev, struct u=
sb_interface *intf)
 		dev->rx_urb_size =3D
 			SR9800_BULKIN_SIZE[SR9800_MAX_BULKIN_2K].size;
 	}
-	netdev_dbg(dev->net, "%s : setting rx_urb_size with : %ld\n", __func_=
_,
+	netdev_dbg(dev->net, "%s : setting rx_urb_size with : %zu\n", __func_=
_,
 		   dev->rx_urb_size);
 	return 0;
=20
--=20
1.7.9.5
