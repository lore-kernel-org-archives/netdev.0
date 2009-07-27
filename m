From: Hannes Eder <heder@google.com>
Subject: [RFC][PATCH 1/5] IPVS: prefix EnterFunction and LeaveFunction msg with
	"IPVS:"
Date: Mon, 27 Jul 2009 15:46:16 +0200
Message-ID: <20090727134616.12897.7639.stgit@jazzy.zrh.corp.google.com>
References: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: lvs-devel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752842AbZG0Pba@vger.kernel.org>
In-Reply-To: <20090727134457.12897.272.stgit@jazzy.zrh.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hannes Eder <hannes@hanneseder.net>

Now all printk messages from IPVS are prefixed with "IPVS:".

Signed-off-by: Hannes Eder <heder@google.com>

 include/net/ip_vs.h |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e01cc2d..e03524e 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -161,18 +161,18 @@ static inline const char *ip_vs_dbg_addr(int af, char *buf, size_t buf_len,
     } while (0)
 
 #ifdef CONFIG_IP_VS_DEBUG
-#define EnterFunction(level)						\
-    do {								\
-	    if (level <= ip_vs_get_debug_level())			\
-		    printk(KERN_DEBUG "Enter: %s, %s line %i\n",	\
-			   __func__, __FILE__, __LINE__);		\
-    } while (0)
-#define LeaveFunction(level)                                            \
-    do {                                                                \
-	    if (level <= ip_vs_get_debug_level())                       \
-			printk(KERN_DEBUG "Leave: %s, %s line %i\n",    \
-			       __func__, __FILE__, __LINE__);       \
-    } while (0)
+#define EnterFunction(level)						       \
+	do {								       \
+		if (level <= ip_vs_get_debug_level())			       \
+			printk(KERN_DEBUG "IPVS: Enter: %s, %s line %i\n",     \
+				__func__, __FILE__, __LINE__);		       \
+	} while (0)
+#define LeaveFunction(level)						       \
+	do {								       \
+		if (level <= ip_vs_get_debug_level())			       \
+			printk(KERN_DEBUG "IPVS: Leave: %s, %s line %i\n",     \
+				__func__, __FILE__, __LINE__);		       \
+	} while (0)
 #else
 #define EnterFunction(level)   do {} while (0)
 #define LeaveFunction(level)   do {} while (0)
