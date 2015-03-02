From: sfeldma@gmail.com
Subject: [PATCH net-next 1/4] rtnetlink: add RTNH_F_EXTERNAL flag for fib offload
Date: Mon,  2 Mar 2015 01:29:12 -0800
Message-ID: <1425288555-22598-2-git-send-email-sfeldma@gmail.com>
References: <1425288555-22598-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34104 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751864AbbCBJaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 04:30:09 -0500
Received: by pdjg10 with SMTP id g10so38322185pdj.1
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 01:30:09 -0800 (PST)
In-Reply-To: <1425288555-22598-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Add new RTNH_F_EXTERNAL flag to mark fib entries offloaded externally, for
example to a switchdev switch.

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
