From: Paul McQuade <paulmcquad@gmail.com>
Subject: [PATCH 3/3] net: wireless: rt2x00: Space Required
Date: Sat, 17 Oct 2015 22:06:45 +0100
Message-ID: <1445116005-28670-3-git-send-email-paulmcquad@gmail.com>
References: <1445116005-28670-1-git-send-email-paulmcquad@gmail.com>
Cc: sgruszka@redhat.com, helmut.schaa@googlemail.com,
	kvalo@codeaurora.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Paul McQuade <paulmcquad@gmail.com#>
To: paulmcquad@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445116005-28670-1-git-send-email-paulmcquad@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Space needed before open parenthesis

Signed-off-by: Paul McQuade <paulmcquad@gmail.com>#
---
 drivers/net/wireless/rt2x00/rt2x00debug.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/rt2x00/rt2x00debug.c
index 90fdb02..25ee3cb 100644
--- a/drivers/net/wireless/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
@@ -629,7 +629,7 @@ static struct dentry *rt2x00debug_create_file_chipset(const char *name,
 	data += sprintf(data, "register\tbase\twords\twordsize\n");
 #define RT2X00DEBUGFS_SPRINTF_REGISTER(__name)			\
 {								\
-	if(debug->__name.read)					\
+	if (debug->__name.read)					\
 		data += sprintf(data, __stringify(__name)	\
 				"\t%d\t%d\t%d\n",		\
 				debug->__name.word_base,	\
@@ -699,7 +699,7 @@ void rt2x00debug_register(struct rt2x00_dev *rt2x00dev)
 
 #define RT2X00DEBUGFS_CREATE_REGISTER_ENTRY(__intf, __name)			\
 ({										\
-	if(debug->__name.read) {						\
+	if (debug->__name.read) {						\
 		(__intf)->__name##_off_entry =					\
 		debugfs_create_u32(__stringify(__name) "_offset",		\
 				       S_IRUSR | S_IWUSR,			\
-- 
2.6.1
