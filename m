From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH] via-velocity: allow MTU size less than 1500 bytes
Date: Tue, 23 May 2006 09:07:01 -0500
Message-ID: <1148393221.2479.29.camel@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf19aec.mail.bellsouth.net ([205.152.59.67]:28258 "EHLO
	imf19aec.mail.bellsouth.net") by vger.kernel.org with ESMTP
	id S1751335AbWEWOHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 May 2006 10:07:04 -0400
Received: from ibm60aec.bellsouth.net ([74.227.55.237])
          by imf19aec.mail.bellsouth.net with ESMTP
          id <20060523140703.UQFF9055.imf19aec.mail.bellsouth.net@ibm60aec.bellsouth.net>
          for <netdev@vger.kernel.org>; Tue, 23 May 2006 10:07:03 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change the minimum allowable MTU size from 1500 bytes to 64 bytes.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>

--- linux-2.6.16.x86_64/drivers/net/via-velocity.h.orig 2006-05-23 07:42:24.000000000 -0500
+++ linux-2.6.16.x86_64/drivers/net/via-velocity.h      2006-05-23 08:31:17.000000000 -0500
@@ -307,7 +307,7 @@
 #define TX_QUEUE_NO         4

 #define MAX_HW_MIB_COUNTER  32
-#define VELOCITY_MIN_MTU    (1514-14)
+#define VELOCITY_MIN_MTU    (64)
 #define VELOCITY_MAX_MTU    (9000)

 /*


