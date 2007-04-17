From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH 1/6] SNMP: Add definitions for {In,Out}BcastPkts
Date: Tue, 17 Apr 2007 20:12:47 +0900
Message-ID: <20070417201247.8d7f4532.mitch@linux.vnet.ibm.com>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:39005 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752892AbXDQLNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 07:13:00 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3HBD0uJ007091
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:13:00 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3HBD0pX483624
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:13:00 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3HBCr4n026386
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:12:54 -0400
In-Reply-To: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The updated IP-MIB RFC (RFC4293) specifys new objects, InBcastPkts
and OutBcastPkts. This adds definitions for them.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 include/linux/snmp.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 854aa6b..802b3a3 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -40,6 +40,8 @@ enum
 	IPSTATS_MIB_FRAGCREATES,		/* FragCreates */
 	IPSTATS_MIB_INMCASTPKTS,		/* InMcastPkts */
 	IPSTATS_MIB_OUTMCASTPKTS,		/* OutMcastPkts */
+	IPSTATS_MIB_INBCASTPKTS,		/* InBcastPkts */
+	IPSTATS_MIB_OUTBCASTPKTS,		/* OutBcastPkts */
 	__IPSTATS_MIB_MAX
 };
 
-- 
1.4.3.4

