From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [CAN] Update documentation of struct sockaddr_can (for 2.6.25)
Date: Sun, 13 Apr 2008 14:26:29 +0200
Message-ID: <4801FBF5.2050209@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090408040303040209010808"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:63460 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756899AbYDMMhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 08:37:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090408040303040209010808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello Dave,

as there are still some things pending for the final 2.6.25 please add 
the following patch to fix the current documentation.

Thanks,
Oliver

------------------

The struct sockaddr_can has been simplified in the code review process. 
This patch updates this simplification also in the associated 
documentation in can.txt .

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>





--------------090408040303040209010808
Content-Type: text/x-diff;
 name="can.txt.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="can.txt.diff"

diff --git a/Documentation/networking/can.txt b/Documentation/networking/can.txt
index f1b2de1..641d2af 100644
--- a/Documentation/networking/can.txt
+++ b/Documentation/networking/can.txt
@@ -281,10 +281,10 @@ solution for a couple of reasons:
             sa_family_t can_family;
             int         can_ifindex;
             union {
-                    struct { canid_t rx_id, tx_id; } tp16;
-                    struct { canid_t rx_id, tx_id; } tp20;
-                    struct { canid_t rx_id, tx_id; } mcnet;
-                    struct { canid_t rx_id, tx_id; } isotp;
+                    /* transport protocol class address info (e.g. ISOTP) */
+                    struct { canid_t rx_id, tx_id; } tp;
+
+                    /* reserved for future CAN protocols address information */
             } can_addr;
     };
 

--------------090408040303040209010808--
