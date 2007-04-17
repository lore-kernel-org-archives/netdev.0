From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Subject: [PATCH 0/6] SNMP: new statistics specified in RFC4293
Date: Tue, 17 Apr 2007 20:09:44 +0900
Message-ID: <20070417200944.bd82ded2.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:36809 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753648AbXDQLJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2007 07:09:57 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l3HB9vEq005183
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:09:57 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l3HB9vMW556928
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:09:57 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l3HB9oFp019976
	for <netdev@vger.kernel.org>; Tue, 17 Apr 2007 07:09:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Let me post a patch set to net-2.6.22 tree for new IPv4 statistics
specified in the updated RFC (RFC4293). All of them (except broadcast
statistics) are already supported in IPv6 stack. However they are not
supported in IPv4 stack yet.

The patch set consists of following 6 patches:

  [PATCH 1/6] SNMP: Add definitions for {In,Out}BcastPkts
  [PATCH 2/6] [IPV4] SNMP: Support InNoRoutes
  [PATCH 3/6] [IPV4] SNMP: Support InTruncatedPkts
  [PATCH 4/6] [IPV4] SNMP: Support InMcastPkts and InBcastPkts
  [PATCH 5/6] [IPV4] SNMP: Support OutMcastPkts and OutBcastPkts
  [PATCH 6/6] [IPV4] SNMP: Display new statistics at /proc/net/snmp

Best Regards,
----
Mitsuru Chinen <mitch@linux.vnet.ibm.com>
