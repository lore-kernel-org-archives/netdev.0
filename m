From: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Subject: [patch 1/2] bluetooth/bt3c: eliminate a sparse warning
Date: Wed, 11 Feb 2009 13:28:11 -0800
Message-ID: <200902112128.n1BLSBnP000351@imap1.linux-foundation.org>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, andre-uV3PkZocewMvJ4zyQN8m6A@public.gmane.org,
	hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andre Haupt <andre-uV3PkZocewMvJ4zyQN8m6A@public.gmane.org>

This eliminates a sparse warning that symbol 'stat' shadows an earlier one.

Signed-off-by: Andre Haupt <andre-uV3PkZocewMvJ4zyQN8m6A@public.gmane.org>
Cc: Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
Cc: Dave Young <hidave.darkstar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
---

 drivers/bluetooth/bt3c_cs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/bluetooth/bt3c_cs.c~bluetooth-bt3c-eliminate-a-sparse-warning drivers/bluetooth/bt3c_cs.c
--- a/drivers/bluetooth/bt3c_cs.c~bluetooth-bt3c-eliminate-a-sparse-warning
+++ a/drivers/bluetooth/bt3c_cs.c
@@ -359,9 +359,9 @@ static irqreturn_t bt3c_interrupt(int ir
 			BT_ERR("Very strange (stat=0x%04x)", stat);
 		} else if ((stat & 0xff) != 0xff) {
 			if (stat & 0x0020) {
-				int stat = bt3c_read(iobase, 0x7002) & 0x10;
+				int status = bt3c_read(iobase, 0x7002) & 0x10;
 				BT_INFO("%s: Antenna %s", info->hdev->name,
-							stat ? "out" : "in");
+							status ? "out" : "in");
 			}
 			if (stat & 0x0001)
 				bt3c_receive(info);
_
