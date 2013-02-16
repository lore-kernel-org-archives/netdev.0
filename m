From: dyoung@redhat.com
Subject: [PATCH]net: ehea module param description fix
Date: Sat, 16 Feb 2013 14:19:19 +0800
Message-ID: <511f24e7.iqc1+9PTu6xF8JTF%dyoung@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8303 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750788Ab3BPGS5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 01:18:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ehea.h the minimal entries is 2^7 - 1:
#define EHEA_MIN_ENTRIES_QP  127

Thus change the module param description accordinglly

Signed-off-by: Dave Young <dyoung@redhat.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_main.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

--- linux-2.6.orig/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ linux-2.6/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -76,16 +76,16 @@ MODULE_PARM_DESC(msg_level, "msg_level")
 MODULE_PARM_DESC(prop_carrier_state, "Propagate carrier state of physical "
 		 "port to stack. 1:yes, 0:no.  Default = 0 ");
 MODULE_PARM_DESC(rq3_entries, "Number of entries for Receive Queue 3 "
-		 "[2^x - 1], x = [6..14]. Default = "
+		 "[2^x - 1], x = [7..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_RQ3) ")");
 MODULE_PARM_DESC(rq2_entries, "Number of entries for Receive Queue 2 "
-		 "[2^x - 1], x = [6..14]. Default = "
+		 "[2^x - 1], x = [7..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_RQ2) ")");
 MODULE_PARM_DESC(rq1_entries, "Number of entries for Receive Queue 1 "
-		 "[2^x - 1], x = [6..14]. Default = "
+		 "[2^x - 1], x = [7..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_RQ1) ")");
 MODULE_PARM_DESC(sq_entries, " Number of entries for the Send Queue  "
-		 "[2^x - 1], x = [6..14]. Default = "
+		 "[2^x - 1], x = [7..14]. Default = "
 		 __MODULE_STRING(EHEA_DEF_ENTRIES_SQ) ")");
 MODULE_PARM_DESC(use_mcs, " Multiple receive queues, 1: enable, 0: disable, "
 		 "Default = 1");
