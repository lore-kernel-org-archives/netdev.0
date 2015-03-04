From: Madhu Challa <challa@noironetworks.com>
Subject: [PATCH iproute2 net-next 1/2] Header rebase for IFA_F_MCAUTOJOIN
Date: Wed,  4 Mar 2015 10:30:09 -0800
Message-ID: <1425493810-2537-2-git-send-email-challa@noironetworks.com>
References: <1425493810-2537-1-git-send-email-challa@noironetworks.com>
Cc: Madhu Challa <challa@noironetworks.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:41198 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759812AbbCDSrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 13:47:24 -0500
Received: by pablj1 with SMTP id lj1so29460068pab.8
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 10:47:23 -0800 (PST)
In-Reply-To: <1425493810-2537-1-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 include/linux/if_addr.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index cc375e4..2033adc 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -50,6 +50,7 @@ enum {
 #define IFA_F_PERMANENT		0x80
 #define IFA_F_MANAGETEMPADDR	0x100
 #define IFA_F_NOPREFIXROUTE	0x200
+#define IFA_F_MCAUTOJOIN	0x400
 
 struct ifa_cacheinfo {
 	__u32	ifa_prefered;
-- 
1.9.1
