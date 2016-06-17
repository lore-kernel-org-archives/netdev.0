From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/7] netfilter: xt_SYNPROXY: add missing header to Kbuild
Date: Fri, 17 Jun 2016 20:25:18 +0200
Message-ID: <1466187919-12800-7-git-send-email-pablo@netfilter.org>
References: <1466187919-12800-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1466187919-12800-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Whitlock says:

 Without this line, the file xt_SYNPROXY.h does not get installed in
 /usr/include/linux/netfilter/, and thus user-space programs cannot make
 use of it.

Reported-by: Matt Whitlock <kernel@mattwhitlock.name>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/Kbuild | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/netfilter/Kbuild b/include/uapi/linux/netfilter/Kbuild
index 1d973d2..cd26d7a 100644
--- a/include/uapi/linux/netfilter/Kbuild
+++ b/include/uapi/linux/netfilter/Kbuild
@@ -33,6 +33,7 @@ header-y += xt_NFLOG.h
 header-y += xt_NFQUEUE.h
 header-y += xt_RATEEST.h
 header-y += xt_SECMARK.h
+header-y += xt_SYNPROXY.h
 header-y += xt_TCPMSS.h
 header-y += xt_TCPOPTSTRIP.h
 header-y += xt_TEE.h
-- 
2.1.4

