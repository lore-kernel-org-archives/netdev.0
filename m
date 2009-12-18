From: Evan McNabb <emcnabb@redhat.com>
Subject: [PATCH] allow nf_tproxy_core module to unload
Date: Fri, 18 Dec 2009 11:24:40 -0500
Message-ID: <20091218162440.22480.3383.sendpatchset@localhost.localdomain>
Cc: Evan McNabb <emcnabb@redhat.com>, sassmann@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:4050 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754539AbZLRQYl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 11:24:41 -0500
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nBIGOfEM011336
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 18 Dec 2009 11:24:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evan McNabb <emcnabb@redhat.com>

Include exit function so nf_tproxy_core module can be removed.

Signed-off-by: Evan McNabb <emcnabb@redhat.com>

diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
index 5490fc3..ec6737c 100644
--- a/net/netfilter/nf_tproxy_core.c
+++ b/net/netfilter/nf_tproxy_core.c
@@ -89,7 +89,12 @@ static int __init nf_tproxy_init(void)
 	return 0;
 }
 
+static void __exit nf_tproxy_exit(void)
+{
+}
+
 module_init(nf_tproxy_init);
+module_exit(nf_tproxy_exit);
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Krisztian Kovacs");
