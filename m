From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 31/31: ebt_ulog: fix checkentry return value
Date: Thu, 10 Sep 2009 18:12:26 +0200 (MEST)
Message-ID: <20090910161222.31179.82109.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 8a56df0ae1690f8f42a3c6c4532f4b06f93febea
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Sep 1 14:34:01 2009 +0200

    netfilter: ebt_ulog: fix checkentry return value
    
    Commit 19eda87 (netfilter: change return types of check functions for
    Ebtables extensions) broke the ebtables ulog module by missing a return
    value conversion.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/bridge/netfilter/ebt_ulog.c b/net/bridge/netfilter/ebt_ulog.c
index 133eeae..ce50688 100644
--- a/net/bridge/netfilter/ebt_ulog.c
+++ b/net/bridge/netfilter/ebt_ulog.c
@@ -266,7 +266,7 @@ static bool ebt_ulog_tg_check(const struct xt_tgchk_param *par)
 	if (uloginfo->qthreshold > EBT_ULOG_MAX_QLEN)
 		uloginfo->qthreshold = EBT_ULOG_MAX_QLEN;
 
-	return 0;
+	return true;
 }
 
 static struct xt_target ebt_ulog_tg_reg __read_mostly = {
