From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 1/3 Rev4] New attribute RTA_AGE
Date: Thu, 20 Sep 2007 20:57:22 +0530
Message-ID: <20070920205722.cad6de2e.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com,
	tgraf@suug.ch, varuncha@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:36964 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756067AbXITP0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 11:26:23 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8KFQHAr008289
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 11:26:17 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8KFQCdU230588
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 09:26:12 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8KFQBSV025258
	for <netdev@vger.kernel.org>; Thu, 20 Sep 2007 09:26:12 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A new attribute RTA_AGE is added for the age value to be exported to userlevel using netlink

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 include/linux/rtnetlink.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index c91476c..68046a4 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -263,6 +263,7 @@ enum rtattr_type_t
 	RTA_SESSION,
 	RTA_MP_ALGO, /* no longer used */
 	RTA_TABLE,
+	RTA_AGE,
 	__RTA_MAX
 };
 
-- 
1.4.3.4

