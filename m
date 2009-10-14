From: jamal <hadi@cyberus.ca>
Subject: [PATCH] iproute2: skbedit: Fix help message
Date: Wed, 14 Oct 2009 08:07:21 -0400
Message-ID: <1255522041.21940.7.camel@dogo.mojatatu.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-S+S43U99zgXBdudXpzb1"
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f172.google.com ([209.85.221.172]:39322 "EHLO
	mail-qy0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759324AbZJNMK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2009 08:10:59 -0400
Received: by qyk2 with SMTP id 2so9663120qyk.21
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2009 05:10:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-S+S43U99zgXBdudXpzb1
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


This fixes the help message on the skbedit action.
Stephen, please apply if Alexander ACKs.

cheers,
jamal

--=-S+S43U99zgXBdudXpzb1
Content-Disposition: attachment; filename=skbe-help
Content-Type: text/plain; name=skbe-help; charset=UTF-8
Content-Transfer-Encoding: 7bit

commit 28dd9c19a1fa618105238a3302f272e2aee7918a
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Tue Oct 14 07:32:51 2009 -0400

    skbedit: Fix help message
    
    Currently the help text implies you can either pass queue mapping
    or priority. Truth is you can pass both
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

diff --git a/tc/m_skbedit.c b/tc/m_skbedit.c
index 9044353..ecb1f2d 100644
--- a/tc/m_skbedit.c
+++ b/tc/m_skbedit.c
@@ -31,8 +31,9 @@
 static void
 explain(void)
 {
-	fprintf(stderr, "Usage: ... skbedit "
-			"queue_mapping QUEUE_MAPPING | priority PRIORITY \n"
+	fprintf(stderr, "Usage: ... skbedit <[QM] [PM]>\n"
+			"QM = queue_mapping QUEUE_MAPPING\n"
+			"PM = priority PRIORITY \n"
 			"QUEUE_MAPPING = device transmit queue to use\n"
 			"PRIORITY = classID to assign to priority field\n");
 }

--=-S+S43U99zgXBdudXpzb1--

