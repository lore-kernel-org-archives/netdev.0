From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] remove include/linux/netfilter_ipv4/ipt_SAME.h
Date: Sun, 17 Feb 2008 10:30:31 +0200
Message-ID: <20080217083031.GY3848@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:37336 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753371AbYBQIa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2008 03:30:57 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the no longer used include/linux/netfilter_ipv4/ipt_SAME.h

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/linux/netfilter_ipv4/Kbuild     |    1 -
 include/linux/netfilter_ipv4/ipt_SAME.h |   19 -------------------
 2 files changed, 20 deletions(-)

553bf355efd03581a094d8a4e0b278e04228aae8 diff --git a/include/linux/netfilter_ipv4/Kbuild b/include/linux/netfilter_ipv4/Kbuild
index 3a7105b..646d104 100644
--- a/include/linux/netfilter_ipv4/Kbuild
+++ b/include/linux/netfilter_ipv4/Kbuild
@@ -7,7 +7,6 @@ header-y += ipt_LOG.h
 header-y += ipt_MARK.h
 header-y += ipt_NFQUEUE.h
 header-y += ipt_REJECT.h
-header-y += ipt_SAME.h
 header-y += ipt_TCPMSS.h
 header-y += ipt_TOS.h
 header-y += ipt_TTL.h
diff --git a/include/linux/netfilter_ipv4/ipt_SAME.h b/include/linux/netfilter_ipv4/ipt_SAME.h
deleted file mode 100644
index be6e682..0000000
--- a/include/linux/netfilter_ipv4/ipt_SAME.h
+++ /dev/null
@@ -1,19 +0,0 @@
-#ifndef _IPT_SAME_H
-#define _IPT_SAME_H
-
-#define IPT_SAME_MAX_RANGE	10
-
-#define IPT_SAME_NODST		0x01
-
-struct ipt_same_info
-{
-	unsigned char info;
-	u_int32_t rangesize;
-	u_int32_t ipnum;
-	u_int32_t *iparray;
-
-	/* hangs off end. */
-	struct nf_nat_range range[IPT_SAME_MAX_RANGE];
-};
-
-#endif /*_IPT_SAME_H*/

