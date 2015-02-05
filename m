From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] chelsio: cxgb4: fix sparse warning
Date: Thu,  5 Feb 2015 15:20:09 +0000
Message-ID: <1423149609-24108-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Hariprasad S <hariprasad@chelsio.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warning:

cxgb4_dcb.c:25:6: warning: symbol 'dcb_ver_array' was not declared. Should it be static?

Alongside making it const.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Found this issue on linux-next (gcc  version 4.8.2,
 sparse version  0.4.5-rc1)and applies on top linux-next.

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index b65a5bd..6074680 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -22,7 +22,7 @@
 
 /* DCBx version control
  */
-char *dcb_ver_array[] = {
+static const char * const dcb_ver_array[] = {
 	"Unknown",
 	"DCBx-CIN",
 	"DCBx-CEE 1.01",
-- 
1.9.1
