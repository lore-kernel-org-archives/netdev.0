From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 0/4 -rev1] Age Entry For IPv4 & IPv6 Route Table
Date: Thu, 26 Jul 2007 10:44:05 +0530
Message-ID: <20070726104405.d5346c68.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:50746 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752100AbXGZFNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 01:13:54 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6Q5DrUq027880
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 01:13:53 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6Q5DpgE529656
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 01:13:53 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6Q5DogW001755
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 01:13:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
   This is the rev 1 of the patch set i sent out earlier. A few changes suggested were added. 

Orginial Message:
   According to the RFC 4292 (IP Forwarding Table MIB) there is a need for an age entry for all the routes in the routing table. The entry in the RFC is inetCidrRouteAge and oid is inetCidrRouteAge.1.10.
Many snmp application require this age entry. So iam adding the age field in the routing table for ipv4 and ipv6 and providing the interface for this value netlink.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---

