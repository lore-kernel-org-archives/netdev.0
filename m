From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/3 nf-next] netfilter: default CONFIG_NETFILTER_INGRESS to y
Date: Mon, 25 May 2015 14:46:40 +0200
Message-ID: <1432558004-13481-2-git-send-email-pablo@netfilter.org>
References: <1432558004-13481-1-git-send-email-pablo@netfilter.org>
Cc: kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1432558004-13481-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Useful to compile-test all options.

Suggested-by: by Alexei Stavoroitov <ast@plumgrid.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/Kconfig |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index db1c674..9a89e7c 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -3,6 +3,7 @@ menu "Core Netfilter Configuration"
 
 config NETFILTER_INGRESS
 	bool "Netfilter ingress support"
+	default y
 	select NET_INGRESS
 	help
 	  This allows you to classify packets from ingress using the Netfilter
-- 
1.7.10.4

