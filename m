From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] selinux/netlabel.c should #include "netlabel.h"
Date: Wed, 27 Feb 2008 23:20:42 +0200
Message-ID: <20080227212042.GK29269@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.or
To: paul.moore@hp.com, sds@tycho.nsa.gov, jmorris@namei.org,
	eparis@parisplace.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:33270 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757605AbYB0VVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2008 16:21:52 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Every file should include the headers containing the externs for its 
global code.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
1f65757bac3e82514b447822ab30ee10d33a59a2 foobar
diff --git a/security/selinux/netlabel.c b/security/selinux/netlabel.c
index 0fa2be4..6d22d76 100644
--- a/security/selinux/netlabel.c
+++ b/security/selinux/netlabel.c
@@ -34,6 +34,7 @@
 
 #include "objsec.h"
 #include "security.h"
+#include "netlabel.h"
 
 /**
  * selinux_netlbl_sidlookup_cached - Cache a SID lookup

