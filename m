From: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
Subject: [PATCH 5/7] e1000e: cleanup: fix space issues in
	ich8_* structs
Date: Thu,  9 Dec 2010 02:40:55 +0000
Message-ID: <1291862457-16671-6-git-send-email-asbjorn__43532.0591008805$1291863651$gmane$org@asbjorn.biz>
References: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <1291862457-16671-1-git-send-email-asbjorn@asbjorn.biz>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Fix 18 checkpatch errors.

Signed-off-by: Asbjoern Sloth Toennesen <asbjorn@asbjorn.biz>
---
 drivers/net/e1000e/ich8lan.c |   36 ++++++++++++++++++------------------
 1 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index c5a7726..a1dec6c 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -162,15 +162,15 @@
 /* Offset 04h HSFSTS */
 union ich8_hws_flash_status {
 	struct ich8_hsfsts {
-		u16 flcdone    :1; /* bit 0 Flash Cycle Done */
-		u16 flcerr     :1; /* bit 1 Flash Cycle Error */
-		u16 dael       :1; /* bit 2 Direct Access error Log */
-		u16 berasesz   :2; /* bit 4:3 Sector Erase Size */
-		u16 flcinprog  :1; /* bit 5 flash cycle in Progress */
-		u16 reserved1  :2; /* bit 13:6 Reserved */
-		u16 reserved2  :6; /* bit 13:6 Reserved */
-		u16 fldesvalid :1; /* bit 14 Flash Descriptor Valid */
-		u16 flockdn    :1; /* bit 15 Flash Config Lock-Down */
+		u16 flcdone:1;    /* bit 0 Flash Cycle Done */
+		u16 flcerr:1;     /* bit 1 Flash Cycle Error */
+		u16 dael:1;       /* bit 2 Direct Access error Log */
+		u16 berasesz:2;   /* bit 4:3 Sector Erase Size */
+		u16 flcinprog:1;  /* bit 5 flash cycle in Progress */
+		u16 reserved1:2;  /* bit 13:6 Reserved */
+		u16 reserved2:6;  /* bit 13:6 Reserved */
+		u16 fldesvalid:1; /* bit 14 Flash Descriptor Valid */
+		u16 flockdn:1;    /* bit 15 Flash Config Lock-Down */
 	} hsf_status;
 	u16 regval;
 };
@@ -179,11 +179,11 @@ union ich8_hws_flash_status {
 /* Offset 06h FLCTL */
 union ich8_hws_flash_ctrl {
 	struct ich8_hsflctl {
-		u16 flcgo      :1;   /* 0 Flash Cycle Go */
-		u16 flcycle    :2;   /* 2:1 Flash Cycle */
-		u16 reserved   :5;   /* 7:3 Reserved  */
-		u16 fldbcount  :2;   /* 9:8 Flash Data Byte Count */
-		u16 flockdn    :6;   /* 15:10 Reserved */
+		u16 flcgo:1;     /* 0 Flash Cycle Go */
+		u16 flcycle:2;   /* 2:1 Flash Cycle */
+		u16 reserved:5;  /* 7:3 Reserved  */
+		u16 fldbcount:2; /* 9:8 Flash Data Byte Count */
+		u16 flockdn:6;   /* 15:10 Reserved */
 	} hsf_ctrl;
 	u16 regval;
 };
@@ -191,10 +191,10 @@ union ich8_hws_flash_ctrl {
 /* ICH Flash Region Access Permissions */
 union ich8_hws_flash_regacc {
 	struct ich8_flracc {
-		u32 grra      :8; /* 0:7 GbE region Read Access */
-		u32 grwa      :8; /* 8:15 GbE region Write Access */
-		u32 gmrag     :8; /* 23:16 GbE Master Read Access Grant */
-		u32 gmwag     :8; /* 31:24 GbE Master Write Access Grant */
+		u32 grra:8;  /* 0:7 GbE region Read Access */
+		u32 grwa:8;  /* 8:15 GbE region Write Access */
+		u32 gmrag:8; /* 23:16 GbE Master Read Access Grant */
+		u32 gmwag:8; /* 31:24 GbE Master Write Access Grant */
 	} hsf_flregacc;
 	u16 regval;
 };
-- 
1.7.2.3


------------------------------------------------------------------------------
This SF Dev2Dev email is sponsored by:

WikiLeaks The End of the Free Internet
http://p.sf.net/sfu/therealnews-com
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
