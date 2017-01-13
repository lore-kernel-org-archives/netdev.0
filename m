From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] tc: m_xt: Drop needless parentheses from #if checks
Date: Fri, 13 Jan 2017 13:06:19 +0100
Message-ID: <20170113120619.27102-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:59209 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752574AbdAMMGW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 07:06:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_xt.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tc/m_xt.c b/tc/m_xt.c
index 57ed40d7aa3a8..e59df8e10afef 100644
--- a/tc/m_xt.c
+++ b/tc/m_xt.c
@@ -77,7 +77,7 @@ static struct xtables_globals tcipt_globals = {
 	.orig_opts = original_opts,
 	.opts = original_opts,
 	.exit_err = NULL,
-#if (XTABLES_VERSION_CODE >= 11)
+#if XTABLES_VERSION_CODE >= 11
 	.compat_rev = xtables_compatible_revision,
 #endif
 };
@@ -126,7 +126,7 @@ static int get_xtables_target_opts(struct xtables_globals *globals,
 {
 	struct option *opts;
 
-#if (XTABLES_VERSION_CODE >= 6)
+#if XTABLES_VERSION_CODE >= 6
 	opts = xtables_options_xfrm(globals->orig_opts,
 				    globals->opts,
 				    m->x6_options,
@@ -204,7 +204,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 			break;
 
 		default:
-#if (XTABLES_VERSION_CODE >= 6)
+#if XTABLES_VERSION_CODE >= 6
 			if (m != NULL && m->x6_parse != NULL) {
 				xtables_option_tpcall(c, argv, 0, m, NULL);
 #else
@@ -242,7 +242,7 @@ static int parse_ipt(struct action_util *a, int *argc_p,
 	}
 
 	/* check that we passed the correct parameters to the target */
-#if (XTABLES_VERSION_CODE >= 6)
+#if XTABLES_VERSION_CODE >= 6
 	if (m)
 		xtables_option_tfcall(m);
 #else
-- 
2.11.0
