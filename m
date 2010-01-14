From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 4/4] netxen: fix sparse warning
Date: Thu, 14 Jan 2010 03:53:24 -0800
Message-ID: <1263470004-30008-5-git-send-email-amit.salecha@qlogic.com>
References: <1263470004-30008-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:60083 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755348Ab0ANLx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 06:53:26 -0500
In-Reply-To: <1263470004-30008-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index e5bdd4d..076f826 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -2596,7 +2596,7 @@ netxen_sysfs_read_mem(struct kobject *kobj, struct bin_attribute *attr,
 	return size;
 }
 
-ssize_t netxen_sysfs_write_mem(struct kobject *kobj,
+static ssize_t netxen_sysfs_write_mem(struct kobject *kobj,
 		struct bin_attribute *attr, char *buf,
 		loff_t offset, size_t size)
 {
-- 
1.6.0.2

