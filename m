From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] include/uapi/linux/sockios.h: mark SIOCRTMSG unused
Date: Tue, 29 Dec 2015 23:22:02 +0100
Message-ID: <1451427722-2672-1-git-send-email-xypron.glpk@gmx.de>
Cc: linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IOCTL SIOCRTMSG does nothing but return EINVAL.

So comment it as unused.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 include/uapi/linux/sockios.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/uapi/linux/sockios.h b/include/uapi/linux/sockios.h
index e888b1a..8e7890b 100644
--- a/include/uapi/linux/sockios.h
+++ b/include/uapi/linux/sockios.h
@@ -27,7 +27,7 @@
 /* Routing table calls. */
 #define SIOCADDRT	0x890B		/* add routing table entry	*/
 #define SIOCDELRT	0x890C		/* delete routing table entry	*/
-#define SIOCRTMSG	0x890D		/* call to routing system	*/
+#define SIOCRTMSG	0x890D		/* unused			*/
 
 /* Socket configuration controls. */
 #define SIOCGIFNAME	0x8910		/* get iface name		*/
-- 
2.1.4
