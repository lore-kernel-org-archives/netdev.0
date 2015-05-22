From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 02/11] mpls: Add definition for IPPROTO_MPLS
Date: Thu, 21 May 2015 17:11:37 -0700
Message-ID: <1432253506-3646977-3-git-send-email-tom@herbertland.com>
References: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <jiri@resnulli.us>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:54170 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756287AbbEVANF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 20:13:05 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4M0CpH8015538
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:13:05 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1uhrt705by-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 May 2015 17:13:05 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 2a2d2d14001711e5a5f20002c95209d8-ce3fc3a0 for <netdev@vger.kernel.org>;	Thu,
 21 May 2015 17:11:59 -0700
In-Reply-To: <1432253506-3646977-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add uapi define for MPLS over IP.

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
