From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 18/19] netfilter: export xt_rpfilter.h to userland
Date: Tue, 20 Aug 2013 12:54:50 +0200
Message-ID: <1376996091-3964-19-git-send-email-pablo@netfilter.org>
References: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60140 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751378Ab3HTKzS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Aug 2013 06:55:18 -0400
In-Reply-To: <1376996091-3964-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

This file contains the API for the match "rpfilter", hence it should be exported
to userland.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/Kbuild              |    1 +
 include/{ => uapi}/linux/netfilter/xt_rpfilter.h |    0
 2 files changed, 1 insertion(+)
 rename include/{ => uapi}/linux/netfilter/xt_rpfilter.h (100%)

diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index 4111577..dc00927 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -68,6 +68,7 @@ header-y += xt_quota.h
 header-y += xt_rateest.h
 header-y += xt_realm.h
 header-y += xt_recent.h
+header-y += xt_rpfilter.h
 header-y += xt_sctp.h
 header-y += xt_set.h
 header-y += xt_socket.h
diff --git a/include/linux/netfilter/xt_rpfilter.h b/include/uapi/linux/netfilter/xt_rpfilter.h
similarity index 100%
rename from include/linux/netfilter/xt_rpfilter.h
rename to include/uapi/linux/netfilter/xt_rpfilter.h
-- 
1.7.10.4
