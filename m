From: Joe Perches <joe@perches.com>
Subject: [PATCH] brcmsmac: Remove unused macro SI_MSG
Date: Fri, 22 Mar 2013 13:00:15 -0700
Message-ID: <25a69b0ba20a54e5c1c0165e68a1ef2c69c84255.1363982285.git.joe@perches.com>
Cc: Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 6236dc2e2 ("brcmsmac: remove some redundant chip common workarounds")
removed the last uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c b/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c
index f0888a9..e4fd1ee 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/aiutils.c
@@ -318,12 +318,6 @@
 #define	IS_SIM(chippkg)	\
 	((chippkg == HDLSIM_PKG_ID) || (chippkg == HWSIM_PKG_ID))
 
-#ifdef DEBUG
-#define	SI_MSG(fmt, ...)	pr_debug(fmt, ##__VA_ARGS__)
-#else
-#define	SI_MSG(fmt, ...)	no_printk(fmt, ##__VA_ARGS__)
-#endif				/* DEBUG */
-
 #define	GOODCOREADDR(x, b) \
 	(((x) >= (b)) && ((x) < ((b) + SI_MAXCORES * SI_CORE_SIZE)) && \
 		IS_ALIGNED((x), SI_CORE_SIZE))
-- 
1.8.1.2.459.gbcd45b4.dirty
