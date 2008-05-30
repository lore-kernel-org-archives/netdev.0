From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/7] tlan: remove unused devName field
Date: Fri, 30 May 2008 09:49:54 -0700
Message-ID: <20080530165033.618674461@vyatta.com>
References: <20080530164951.033143725@vyatta.com>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>, Samuel Chessman <chessman@tux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([69.59.150.140]:34081 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751892AbYE3Qx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 12:53:57 -0400
Content-Disposition: inline; filename=tlan-devname.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/tlan.h	2008-05-30 08:50:29.000000000 -0700
+++ b/drivers/net/tlan.h	2008-05-30 08:50:34.000000000 -0700
@@ -204,7 +204,6 @@ typedef struct tlan_private_tag {
 	u32			speed;
 	u8			tlanRev;
 	u8			tlanFullDuplex;
-	char                    devName[8];
 	spinlock_t		lock;
 	u8			link;
 	u8			is_eisa;

-- 

