From: Joe Perches <joe@perches.com>
Subject: [PATCH 53/62] carl9170: Use static const
Date: Sat, 20 Nov 2010 18:38:54 -0800
Message-ID: <d94b7e1a273107e3b04709615cbf31ef1b92d87a.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   1897	     56	    672	   2625	    a41	drivers/net/wireless/ath/carl9170/cmd.o.new
   1897	     56	    672	   2625	    a41	drivers/net/wireless/ath/carl9170/cmd.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/carl9170/cmd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/cmd.c b/drivers/net/wireless/ath/carl9170/cmd.c
index c21f336..cdfc94c 100644
--- a/drivers/net/wireless/ath/carl9170/cmd.c
+++ b/drivers/net/wireless/ath/carl9170/cmd.c
@@ -41,7 +41,7 @@
 
 int carl9170_write_reg(struct ar9170 *ar, const u32 reg, const u32 val)
 {
-	__le32 buf[2] = {
+	const __le32 buf[2] = {
 		cpu_to_le32(reg),
 		cpu_to_le32(val),
 	};
-- 
1.7.3.2.245.g03276.dirty
