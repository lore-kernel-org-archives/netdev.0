From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 6/8] net: ipv4: add new RTM_F_FIB_MATCH flag for use with RTM_GETROUTE
Date: Thu, 25 May 2017 10:42:38 -0700
Message-ID: <1495734160-47659-7-git-send-email-roopa@cumulusnetworks.com>
References: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: davem@davemloft.net, dsahern@gmail.com, rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:33220 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S969992AbdEYRnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 May 2017 13:43:09 -0400
Received: by mail-pf0-f174.google.com with SMTP id e193so173727085pfh.0
        for <netdev@vger.kernel.org>; Thu, 25 May 2017 10:43:08 -0700 (PDT)
In-Reply-To: <1495734160-47659-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This flag when specified will return matched fib result in
response to a RTM_GETROUTE query.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/uapi/linux/rtnetlink.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 6487b21..564790e 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -278,6 +278,7 @@ enum rt_scope_t {
 #define RTM_F_EQUALIZE		0x400	/* Multipath equalizer: NI	*/
 #define RTM_F_PREFIX		0x800	/* Prefix addresses		*/
 #define RTM_F_LOOKUP_TABLE	0x1000	/* set rtm_table to FIB lookup result */
+#define RTM_F_FIB_MATCH	        0x2000	/* return full fib lookup match */
 
 /* Reserved table identifiers */
 
-- 
1.9.1
