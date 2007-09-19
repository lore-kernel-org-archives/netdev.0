From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [RESEND][PATCH 1/4 Rev-3] New attribute RTA_AGE
Date: Wed, 19 Sep 2007 09:23:43 +0530
Message-ID: <20070919092343.bb578cde.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com,
	tgraf@suug.ch, varuncha@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:44210 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751540AbXISDwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 23:52:34 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8J3qYM4014337
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 23:52:34 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8J3qYI9501430
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 21:52:34 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8J3qXpL006562
	for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 21:52:33 -0600
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

