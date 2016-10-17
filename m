From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 1/7] ipv6: Fix Makefile conditional to use CONFIG_INET
Date: Mon, 17 Oct 2016 12:41:56 -0700
Message-ID: <20161017194202.3510238-2-tom@herbertland.com>
References: <20161017194202.3510238-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50478 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932205AbcJQTmK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 15:42:10 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u9HJfeD1008141
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 12:42:10 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 26512nn93h-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 12:42:10 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 ca29da9094a111e680cb24be0593f280-6feeda50 for <netdev@vger.kernel.org>;        Mon,
 17 Oct 2016 12:42:08 -0700
In-Reply-To: <20161017194202.3510238-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6 directory was being built based on CONFIG_NET not CONFIG_INET.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/Makefile | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/Makefile b/net/Makefile
index 4cafaa2..82ffb91 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -17,7 +17,7 @@ obj-$(CONFIG_NETFILTER)		+= netfilter/
 obj-$(CONFIG_INET)		+= ipv4/
 obj-$(CONFIG_XFRM)		+= xfrm/
 obj-$(CONFIG_UNIX)		+= unix/
-obj-$(CONFIG_NET)		+= ipv6/
+obj-$(CONFIG_INET)		+= ipv6/
 obj-$(CONFIG_PACKET)		+= packet/
 obj-$(CONFIG_NET_KEY)		+= key/
 obj-$(CONFIG_BRIDGE)		+= bridge/
-- 
2.9.3
