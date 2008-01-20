From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED]: kill obsolete NET_CLS_POLICE option
Date: Sun, 20 Jan 2008 15:48:16 +0100
Message-ID: <47935F30.9080106@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070200080308000309020702"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59533 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467AbYATOtQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:49:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070200080308000309020702
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------070200080308000309020702
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 2af10cb220dd73b91323d052f7ca4cb808906e78
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Jan 16 12:22:06 2008 +0100

    [NET_SCHED]: kill obsolete NET_CLS_POLICE option
    
    The code is already gone for about half a year, the config option
    has been kept around to select the replacement options for easier
    upgrades. This seems long enough, people upgrading from older
    kernels will have to reconfigure a lot anyway.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 63882c5..4eb73ec 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -481,15 +481,6 @@ config NET_ACT_SIMP
 	  To compile this code as a module, choose M here: the
 	  module will be called simple.
 
-config NET_CLS_POLICE
-	bool "Traffic Policing (obsolete)"
-	select NET_CLS_ACT
-	select NET_ACT_POLICE
-	---help---
-	  Say Y here if you want to do traffic policing, i.e. strict
-	  bandwidth limiting. This option is obsolete and just selects
-	  the option replacing it. It will be removed in the future.
-
 config NET_CLS_IND
 	bool "Incoming device classification"
 	depends on NET_CLS_U32 || NET_CLS_FW

--------------070200080308000309020702--
