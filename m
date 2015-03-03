From: sfeldma@gmail.com
Subject: [PATCH net-next v3 1/7] rtnetlink: add RTNH_F_EXTERNAL flag for fib offload
Date: Tue,  3 Mar 2015 15:31:54 -0800
Message-ID: <1425425520-34017-2-git-send-email-sfeldma@gmail.com>
References: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:42506 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757651AbbCCXa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2015 18:30:58 -0500
Received: by padfa1 with SMTP id fa1so28064631pad.9
        for <netdev@vger.kernel.org>; Tue, 03 Mar 2015 15:30:58 -0800 (PST)
In-Reply-To: <1425425520-34017-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add new RTNH_F_EXTERNAL flag to mark fib entries offloaded externally, for
example to a switchdev switch device.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/uapi/linux/rtnetlink.h |    1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 5cc5d66..b476e86 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -332,6 +332,7 @@ struct rtnexthop {
 #define RTNH_F_DEAD		1	/* Nexthop is dead (used by multipath)	*/
 #define RTNH_F_PERVASIVE	2	/* Do recursive gateway lookup	*/
 #define RTNH_F_ONLINK		4	/* Gateway is forced on link	*/
+#define RTNH_F_EXTERNAL		8	/* Route installed externally	*/
 
 /* Macros to handle hexthops */
 
-- 
1.7.10.4
