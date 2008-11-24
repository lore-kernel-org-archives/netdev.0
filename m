From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/03: xtables: add missing const qualifier to xt_tgchk_param
Date: Mon, 24 Nov 2008 14:44:38 +0100 (MET)
Message-ID: <20081124134430.462.41146.sendpatchset@x2.localnet>
References: <20081124134427.462.77824.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081124134427.462.77824.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 511bb54d5b276711ce08ab7e63f53226890b0e35
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Wed Nov 19 13:47:24 2008 +0100

    netfilter: xtables: add missing const qualifier to xt_tgchk_param
    
    When entryinfo was a standalone parameter to functions, it used to be
    "const void *". Put the const back in.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index be41b60..e52ce47 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -251,7 +251,7 @@ struct xt_target_param {
  */
 struct xt_tgchk_param {
 	const char *table;
-	void *entryinfo;
+	const void *entryinfo;
 	const struct xt_target *target;
 	void *targinfo;
 	unsigned int hook_mask;
