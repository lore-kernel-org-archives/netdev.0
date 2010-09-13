From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/25] drivers/net/qlcnic: Use static const char arrays
Date: Mon, 13 Sep 2010 12:47:50 -0700
Message-ID: <4f9ef3036179e7a6cf4d238fad64920d8130015c.1284406638.git.joe@perches.com>
References: <cover.1284406638.git.joe@perches.com>
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1284406638.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/qlcnic/qlcnic.h      |    2 +-
 drivers/net/qlcnic/qlcnic_main.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index cc8385a..7effdad 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -345,7 +345,7 @@ struct uni_data_desc{
 #define QLCNIC_UNIFIED_ROMIMAGE_NAME	"phanfw.bin"
 #define QLCNIC_FLASH_ROMIMAGE_NAME	"flash"
 
-extern char qlcnic_driver_name[];
+extern const char qlcnic_driver_name[];
 
 /* Number of status descriptors to handle per interrupt */
 #define MAX_STATUS_HANDLE	(64)
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 5fd2abd..ad40171 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -41,7 +41,7 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(QLCNIC_LINUX_VERSIONID);
 MODULE_FIRMWARE(QLCNIC_UNIFIED_ROMIMAGE_NAME);
 
-char qlcnic_driver_name[] = "qlcnic";
+const char qlcnic_driver_name[] = "qlcnic";
 static const char qlcnic_driver_string[] = "QLogic 1/10 GbE "
 	"Converged/Intelligent Ethernet Driver v" QLCNIC_LINUX_VERSIONID;
 
-- 
1.7.3.rc1
