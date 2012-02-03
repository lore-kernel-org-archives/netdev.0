From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 1/2] netfilter: remove include/linux/netfilter_ipv4/ipt_addrtype.h
Date: Fri,  3 Feb 2012 13:40:25 +0800
Message-ID: <1328247626-7528-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: netfilter-devel@vger.kernel.org,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Florian Westphal <fw@strlen.de>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
 Documentation/feature-removal-schedule.txt  |    8 --------
 include/linux/netfilter_ipv4/Kbuild         |    1 -
 include/linux/netfilter_ipv4/ipt_addrtype.h |   27 ---------------------------
 3 files changed, 0 insertions(+), 36 deletions(-)
 delete mode 100644 include/linux/netfilter_ipv4/ipt_addrtype.h

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index a0ffac0..830a0b9 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -422,14 +422,6 @@ Files:	net/netfilter/xt_connlimit.c
 
 ----------------------------
 
-What:	ipt_addrtype match include file
-When:	2012
-Why:	superseded by xt_addrtype
-Who:	Florian Westphal <fw@strlen.de>
-Files:	include/linux/netfilter_ipv4/ipt_addrtype.h
-
-----------------------------
-
 What:	i2c_driver.attach_adapter
 	i2c_driver.detach_adapter
 When:	September 2011
diff --git a/include/linux/netfilter_ipv4/Kbuild b/include/linux/netfilter_ipv4/Kbuild
index f9930c8..8e6362b 100644
--- a/include/linux/netfilter_ipv4/Kbuild
+++ b/include/linux/netfilter_ipv4/Kbuild
@@ -7,7 +7,6 @@ header-y += ipt_REJECT.h
 header-y += ipt_SAME.h
 header-y += ipt_TTL.h
 header-y += ipt_ULOG.h
-header-y += ipt_addrtype.h
 header-y += ipt_ah.h
 header-y += ipt_ecn.h
 header-y += ipt_realm.h
diff --git a/include/linux/netfilter_ipv4/ipt_addrtype.h b/include/linux/netfilter_ipv4/ipt_addrtype.h
deleted file mode 100644
index 0da4223..0000000
--- a/include/linux/netfilter_ipv4/ipt_addrtype.h
+++ /dev/null
@@ -1,27 +0,0 @@
-#ifndef _IPT_ADDRTYPE_H
-#define _IPT_ADDRTYPE_H
-
-#include <linux/types.h>
-
-enum {
-	IPT_ADDRTYPE_INVERT_SOURCE	= 0x0001,
-	IPT_ADDRTYPE_INVERT_DEST	= 0x0002,
-	IPT_ADDRTYPE_LIMIT_IFACE_IN	= 0x0004,
-	IPT_ADDRTYPE_LIMIT_IFACE_OUT	= 0x0008,
-};
-
-struct ipt_addrtype_info_v1 {
-	__u16	source;		/* source-type mask */
-	__u16	dest;		/* dest-type mask */
-	__u32	flags;
-};
-
-/* revision 0 */
-struct ipt_addrtype_info {
-	__u16	source;		/* source-type mask */
-	__u16	dest;		/* dest-type mask */
-	__u32	invert_source;
-	__u32	invert_dest;
-};
-
-#endif
-- 
1.7.7.6

