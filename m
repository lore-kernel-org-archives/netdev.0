From: frank.blaschka@de.ibm.com
Subject: [patch 1/5] [PATCH] qeth: enable kmsg hash processing in qeth_core_sys.c
Date: Tue, 09 Mar 2010 07:36:53 +0100
Message-ID: <20100309063936.407301000@de.ibm.com>
References: <20100309063652.706791000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:58842 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915Ab0CIGji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 01:39:38 -0500
Content-Disposition: inline; filename=601-qeth-kmsg.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

provide qeth kmsg definitions to enable hash string generation for
kernel message created with dev_err().

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_sys.c |    3 +++
 1 file changed, 3 insertions(+)

--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -8,6 +8,9 @@
  *		 Frank Blaschka <frank.blaschka@de.ibm.com>
  */
 
+#define KMSG_COMPONENT "qeth"
+#define pr_fmt(fmt) KMSG_COMPONENT ": " fmt
+
 #include <linux/list.h>
 #include <linux/rwsem.h>
 #include <asm/ebcdic.h>

