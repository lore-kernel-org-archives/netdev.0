From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH] net bridge: remove unused field
Date: Mon, 14 Oct 2013 17:11:09 -0400
Message-ID: <525C5DED.1080406@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020004080708080408040005"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f42.google.com ([209.85.216.42]:59584 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756815Ab3JNVLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 17:11:22 -0400
Received: by mail-qa0-f42.google.com with SMTP id w8so2852612qac.1
        for <netdev@vger.kernel.org>; Mon, 14 Oct 2013 14:11:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020004080708080408040005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trivial patch

cheers,
jamal

--------------020004080708080408040005
Content-Type: text/plain; charset=UTF-8;
 name="patch-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="patch-1"

commit 984b1bc7c51a1201707238f7aa5fa1a8b72fde90
Author: jamal <jhs@mojatatu.com>
Date:   Mon Oct 14 17:04:16 2013 -0400

    Remove unused enum
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 80394e8..f8dab16 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -209,11 +209,6 @@ enum {
 #define IFLA_INET6_MAX	(__IFLA_INET6_MAX - 1)
 
 enum {
-	BRIDGE_MODE_UNSPEC,
-	BRIDGE_MODE_HAIRPIN,
-};
-
-enum {
 	IFLA_BRPORT_UNSPEC,
 	IFLA_BRPORT_STATE,	/* Spanning tree state     */
 	IFLA_BRPORT_PRIORITY,	/* "             priority  */

--------------020004080708080408040005--
