From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH 6/6] [IPV4] SNMP: Display new statistics at /proc/net/snmp
Date: Tue, 17 Apr 2007 20:14:36 +0900
Message-ID: <20070417201436.ab8f3f7a.mitch@linux.vnet.ibm.com>
References: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:42758 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753821AbXDQLOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 07:14:49 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3HBEmm1023530
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:14:48 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3HBEmDd530112
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:14:48 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3HBEg2A028469
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:14:42 -0400
In-Reply-To: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This displays the statistics specified in the updated IP-MIB RFC
(RFC4293) at /proc/net/snmp. As new statistics are placed as the
last elements, this change wouldn't affect netstat, net-snmp, etc.

Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
---
 net/ipv4/proc.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index ae68a69..cc4c80a 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -119,6 +119,12 @@ static const struct snmp_mib snmp4_ipsta
 	SNMP_MIB_ITEM("FragOKs", IPSTATS_MIB_FRAGOKS),
 	SNMP_MIB_ITEM("FragFails", IPSTATS_MIB_FRAGFAILS),
 	SNMP_MIB_ITEM("FragCreates", IPSTATS_MIB_FRAGCREATES),
+	SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
+	SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPKTS),
+	SNMP_MIB_ITEM("InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
+	SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
+	SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
+	SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
 	SNMP_MIB_SENTINEL
 };
 
-- 
1.4.3.4

