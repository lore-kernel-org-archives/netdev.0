From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 1/4] New attribute RTA_AGE
Date: Mon, 23 Jul 2007 10:11:13 +0530
Message-ID: <20070723101113.0a1f2eeb.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dlstevens@us.ibm.com, varuncha@in.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:47780 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511AbXGWElA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 00:41:00 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6N4exni031791
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 00:40:59 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6N4exwf209372
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 22:40:59 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6N4exjK004257
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 22:40:59 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A new attribute RTA_AGE is added for the age value to be exported to userlevel using netlink

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---
 include/linux/rtnetlink.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 6127858..884f507 100644
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

