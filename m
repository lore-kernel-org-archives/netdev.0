From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] prism54: use NULL for pointer
Date: Sat, 22 Jan 2005 22:53:35 -0800
Message-ID: <20050122225335.225f8042.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>, prism54-private@prism54.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Use NULL instead of 0 for pointer:

drivers/net/wireless/prism54/isl_ioctl.c:1753:16: warning: Using plain integer as NULL pointer
drivers/net/wireless/prism54/isl_ioctl.c:1753:26: warning: Using plain integer as NULL pointer

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/wireless/prism54/isl_ioctl.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./drivers/net/wireless/prism54/isl_ioctl.c~prism54_isl_null ./drivers/net/wireless/prism54/isl_ioctl.c
--- ./drivers/net/wireless/prism54/isl_ioctl.c~prism54_isl_null	2005-01-22 21:53:00.599920368 -0800
+++ ./drivers/net/wireless/prism54/isl_ioctl.c	2005-01-22 21:53:58.223160304 -0800
@@ -1750,7 +1750,7 @@ prism54_process_trap_helper(islpci_priva
 	u8 wpa_ie[MAX_WPA_IE_LEN];
 	int wpa_ie_len;
 	size_t len = 0; /* u16, better? */
-	u8 *payload = 0, *pos = 0;
+	u8 *payload = NULL, *pos = NULL;
 	int ret;
 
 	/* I think all trapable objects are listed here.

--
