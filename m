From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v6 net-next 02/11] mpls: Add definition for IPPROTO_MPLS
Date: Thu, 4 Jun 2015 09:16:37 -0700
Message-ID: <1433434606-527444-3-git-send-email-tom@herbertland.com>
References: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:1551 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753078AbbFDQRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 12:17:06 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t54GFfZ8030450
	for <netdev@vger.kernel.org>; Thu, 4 Jun 2015 09:17:05 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1utrt58aq3-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 09:17:05 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 2339b5cc0ad511e5ba0e0002c992ebde-bf6bb6c0 for <netdev@vger.kernel.org>;	Thu,
 04 Jun 2015 09:17:04 -0700
In-Reply-To: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add uapi define for MPLS over IP.

Acked-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/uapi/linux/in.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
index 589ced0..641338b 100644
--- a/include/uapi/linux/in.h
+++ b/include/uapi/linux/in.h
@@ -69,6 +69,8 @@ enum {
 #define IPPROTO_SCTP		IPPROTO_SCTP
   IPPROTO_UDPLITE = 136,	/* UDP-Lite (RFC 3828)			*/
 #define IPPROTO_UDPLITE		IPPROTO_UDPLITE
+  IPPROTO_MPLS = 137,		/* MPLS in IP (RFC 4023)		*/
+#define IPPROTO_MPLS		IPPROTO_MPLS
   IPPROTO_RAW = 255,		/* Raw IP packets			*/
 #define IPPROTO_RAW		IPPROTO_RAW
   IPPROTO_MAX
-- 
1.8.1
