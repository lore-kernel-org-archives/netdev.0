From: Flavio Leitner <fbl@redhat.com>
Subject: [net-next] dummy: use MODULE_VERSION
Date: Tue,  9 Dec 2014 22:41:48 -0200
Message-ID: <1418172108-10522-1-git-send-email-fbl@redhat.com>
Cc: Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752997AbaLJAl5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Dec 2014 19:41:57 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id sBA0fuSS003996
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 9 Dec 2014 19:41:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use MODULE_VERSION() now that dummy driver has a version.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/dummy.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 413ca4f..49adbf1 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -225,3 +225,4 @@ module_init(dummy_init_module);
 module_exit(dummy_cleanup_module);
 MODULE_LICENSE("GPL");
 MODULE_ALIAS_RTNL_LINK(DRV_NAME);
+MODULE_VERSION(DRV_VERSION);
-- 
1.9.3
