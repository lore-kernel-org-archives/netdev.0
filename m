From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [PATCH] net: Update entry in af_family_clock_key_strings
Date: Wed, 23 Jul 2008 22:28:58 +0200
Message-ID: <4887948A.6030304@hartkopp.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060903080300060203060402"
Cc: Urs Thuermann <urs@isnogud.escape.de>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:44651 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755919AbYGWU3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 16:29:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060903080300060203060402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

In the merge phase of the CAN subsystem the 
af_family_clock_key_strings[] have been added to sock.c in commit 
443aef0eddfa44c158d1b94ebb431a70638fcab4 
(lockdep: fixup sk_callback_lock annotation). This trivial patch adds 
the missing name for address family 29 (AF_CAN).

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
Cc: Urs Thuermann <urs@isnogud.escape.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>

---



--------------060903080300060203060402
Content-Type: text/x-patch;
 name="sock-AF_CAN-clock-key-string.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="sock-AF_CAN-clock-key-string.patch"

diff --git a/net/core/sock.c b/net/core/sock.c
index 10a64d5..91f8bbc 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -180,7 +180,7 @@ static const char *af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_ASH"   , "clock-AF_ECONET"   , "clock-AF_ATMSVC"   ,
   "clock-21"       , "clock-AF_SNA"      , "clock-AF_IRDA"     ,
   "clock-AF_PPPOX" , "clock-AF_WANPIPE"  , "clock-AF_LLC"      ,
-  "clock-27"       , "clock-28"          , "clock-29"          ,
+  "clock-27"       , "clock-28"          , "clock-AF_CAN"      ,
   "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
   "clock-AF_RXRPC" , "clock-AF_MAX"
 };

--------------060903080300060203060402--
