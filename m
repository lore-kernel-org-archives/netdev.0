From: Eric Leblond <eric@inl.fr>
Subject: [PATCH 3/3] netfilter: fix nf_logger name in ebt_ulog.
Date: Thu, 26 Mar 2009 08:59:56 +0100
Message-ID: <1238054396-9088-3-git-send-email-eric@inl.fr>
References: <1238053819.13879.4.camel@ice-age>
Cc: linux-next@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Eric Leblond <eric@inl.fr>
To: davem@davemloft.net, kaber@trash.net, sfr@canb.auug.org.au
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1238053819.13879.4.camel@ice-age>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch renames the ebt_ulog nf_logger from "ulog" to "ebt_ulog" to
be in sync with other modules naming. As this name was currently only
used for informational purpose, the renaming should be harmless.

Signed-off-by: Eric Leblond <eric@inl.fr>
---
 net/bridge/netfilter/ebt_ulog.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index ac6fa43..133eeae 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -280,7 +280,7 @@ static struct xt_target ebt_ulog_tg_reg __read_mostly = {
 };
 
 static struct nf_logger ebt_ulog_logger __read_mostly = {
-	.name		= "ulog",
+	.name		= "ebt_ulog",
 	.logfn		= &ebt_log_packet,
 	.me		= THIS_MODULE,
 };
-- 
1.5.6.3

