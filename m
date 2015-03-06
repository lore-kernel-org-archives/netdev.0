From: sfeldma@gmail.com
Subject: [PATCH net-next v4 1/8] rtnetlink: add RTNH_F_EXTERNAL flag for fib offload
Date: Thu,  5 Mar 2015 21:21:13 -0800
Message-ID: <1425619280-27492-2-git-send-email-sfeldma@gmail.com>
References: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jiri@resnulli.us,
	roopa@cumulusnetworks.com, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:41649 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbbCFFUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 00:20:35 -0500
Received: by pdjy10 with SMTP id y10so2500376pdj.8
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 21:20:35 -0800 (PST)
In-Reply-To: <1425619280-27492-1-git-send-email-sfeldma@gmail.com>
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
index 06f75a4..c3722b0 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -334,6 +334,7 @@ struct rtnexthop {
 #define RTNH_F_DEAD		1	/* Nexthop is dead (used by multipath)	*/
 #define RTNH_F_PERVASIVE	2	/* Do recursive gateway lookup	*/
 #define RTNH_F_ONLINK		4	/* Gateway is forced on link	*/
+#define RTNH_F_EXTERNAL		8	/* Route installed externally	*/
 
 /* Macros to handle hexthops */
 
-- 
1.7.10.4
