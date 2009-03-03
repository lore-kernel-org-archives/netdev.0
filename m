From: Meelis Roos <mroos@linux.ee>
Subject: [PATCH] fix tokenring license
Date: Tue, 3 Mar 2009 20:11:26 +0200 (EET)
Message-ID: <Pine.SOC.4.64.0903031933400.26090@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:50613 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752271AbZCCSLc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2009 13:11:32 -0500
Received: from math.ut.ee (math.ut.ee [193.40.36.2])
	by smtp2.it.da.ut.ee (Postfix) with ESMTP id B1A0B73D7A1
	for <netdev@vger.kernel.org>; Tue,  3 Mar 2009 20:11:26 +0200 (EET)
Received: from localhost (localhost [127.0.0.1])
	by math.ut.ee (Postfix) with ESMTP id A4F7FFD79B
	for <netdev@vger.kernel.org>; Tue,  3 Mar 2009 20:11:26 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, modular tokenring ("tr") lacks a license and fails to load:

tr: module license 'unspecified' taints kernel.
tr: Unknown symbol proc_net_fops_create

Beacuse of this, no tokenring driver can load if it depends on modular 
tr. Fix this by adding GPL module license as it is in the kernel.

With this fix, tr module loads fine and tms380 driver also loads. Well, 
it does'nt work but that's a different bug.

Signed-off-by: Meelis Roos <mroos@linux.ee>

diff --git a/net/802/tr.c b/net/802/tr.c
index 158150f..f47ae28 100644
--- a/net/802/tr.c
+++ b/net/802/tr.c
@@ -668,3 +668,5 @@ module_init(rif_init);
 
 EXPORT_SYMBOL(tr_type_trans);
 EXPORT_SYMBOL(alloc_trdev);
+
+MODULE_LICENSE("GPL");

-- 
Meelis Roos (mroos@linux.ee)
