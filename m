From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next 6/8] net: ipv4: add new RTM_F_FIB_MATCH flag for use with RTM_GETROUTE
Date: Wed, 24 May 2017 11:19:09 -0700
Message-ID: <1495649951-30417-7-git-send-email-roopa@cumulusnetworks.com>
References: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, dsahern@gmail.com,
        nikolay@cumulusnetworks.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:35359 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933768AbdEXSTV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 14:19:21 -0400
Received: by mail-pf0-f177.google.com with SMTP id n23so143184356pfb.2
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 11:19:21 -0700 (PDT)
In-Reply-To: <1495649951-30417-1-git-send-email-roopa@cumulusnetworks.com>
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
