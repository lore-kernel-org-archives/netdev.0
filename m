From: jamal <hadi@cyberus.ca>
Subject: [PATCH 1/2] iproute2 skbedit: Fix help message
Date: Thu, 03 Dec 2009 08:27:24 -0500
Message-ID: <1259846844.3766.36.camel@bigi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-EIZzqkKmtnatIuMNysCd"
Cc: netdev@vger.kernel.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:41049 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbZLCN1W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 08:27:22 -0500
Received: by vws30 with SMTP id 30so598181vws.33
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2009 05:27:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-EIZzqkKmtnatIuMNysCd
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


Currently the help text for skbedit implies you can either pass queue
mapping or priority. Truth is you can pass both

cheers,
jamal


--=-EIZzqkKmtnatIuMNysCd
Content-Disposition: attachment; filename="skbehelp-p"
Content-Type: text/plain; name="skbehelp-p"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

commit ca50bc332fc8f2cba0468fe133d41d78a0be7b71
Author: Jamal Hadi Salim <hadi@cyberus.ca>
Date:   Thu Dec 3 08:14:11 2009 -0500

    skbedit: Fix help message
    
    Currently the help text implies you can either pass queue mapping
    or priority. Truth is you can pass both
    
    Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
    Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

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

--=-EIZzqkKmtnatIuMNysCd--

