From: Joe Perches <joe@perches.com>
Subject: [PATCH next 09/16] drivers/net/wireless: Use static const char * const where possible
Date: Mon, 13 Sep 2010 21:23:55 -0700
Message-ID: <ccc9236f25803fbd8bc082e4fef2af8a0885ebf4.1284435710.git.joe@perches.com>
References: <cover.1284435709.git.joe@perches.com>
Cc: Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1284435709.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rt2x00/rt2x00debug.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/rt2x00/rt2x00debug.c
index b8cf45c..c1710b2 100644
--- a/drivers/net/wireless/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
@@ -380,7 +380,7 @@ static ssize_t rt2x00debug_read_crypto_stats(struct file *file,
 					     loff_t *offset)
 {
 	struct rt2x00debug_intf *intf = file->private_data;
-	char *name[] = { "WEP64", "WEP128", "TKIP", "AES" };
+	static const char * const name[] = { "WEP64", "WEP128", "TKIP", "AES" };
 	char *data;
 	char *temp;
 	size_t size;
-- 
1.7.3.rc1
