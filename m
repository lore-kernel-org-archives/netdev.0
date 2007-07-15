From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] ipt_iprange.h must #include <linux/types.h>
Date: Sun, 15 Jul 2007 14:14:19 +0200
Message-ID: <20070715121419.GK3565@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, kaber@coreworks.de,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org,
	cilly <cilly@cilly.mine.nu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:33816 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758943AbXGOMO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 08:14:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ipt_iprange.h must #include <linux/types.h> since it uses __be32.

This patch fixes kernel Bugzilla #7604.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---
--- linux-2.6.22-rc6-mm1/include/linux/netfilter_ipv4/ipt_iprange.h.old	2007-07-15 13:07:40.000000000 +0200
+++ linux-2.6.22-rc6-mm1/include/linux/netfilter_ipv4/ipt_iprange.h	2007-07-15 13:07:55.000000000 +0200
@@ -1,6 +1,8 @@
 #ifndef _IPT_IPRANGE_H
 #define _IPT_IPRANGE_H
 
+#include <linux/types.h>
+
 #define IPRANGE_SRC		0x01	/* Match source IP address */
 #define IPRANGE_DST		0x02	/* Match destination IP address */
 #define IPRANGE_SRC_INV		0x10	/* Negate the condition */
