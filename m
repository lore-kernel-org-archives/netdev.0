From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 19/19] netfilter: export xt_HMARK.h to userland
Date: Tue, 20 Aug 2013 12:54:51 +0200
Message-ID: <1376996091-3964-20-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60145 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751242Ab3HTKzS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:18 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

This file contains the API for the target "HMARK", hence it should be exported
to userland.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/Kbuild           |    1 +
 include/{ => uapi}/linux/netfilter/xt_HMARK.h |    0
 2 files changed, 1 insertion(+)
 rename include/{ => uapi}/linux/netfilter/xt_HMARK.h (100%)

diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index dc00927..1749154 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -22,6 +22,7 @@ header-y += xt_CONNMARK.h
 header-y += xt_CONNSECMARK.h
 header-y += xt_CT.h
 header-y += xt_DSCP.h
+header-y += xt_HMARK.h
 header-y += xt_IDLETIMER.h
 header-y += xt_LED.h
 header-y += xt_LOG.h
diff --git a/include/linux/netfilter/xt_HMARK.h b/include/uapi/linux/netfilter/xt_HMARK.h
similarity index 100%
rename from include/linux/netfilter/xt_HMARK.h
rename to include/uapi/linux/netfilter/xt_HMARK.h
-- 
1.7.10.4
