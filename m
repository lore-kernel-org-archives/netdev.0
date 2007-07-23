From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 0/4] Age Entry For IPv4 & IPv6 Route Table
Date: Mon, 23 Jul 2007 10:09:57 +0530
Message-ID: <20070723100957.ca476679.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, dlstevens@us.ibm.com, varuncha@in.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:55503 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751912AbXGWEjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2007 00:39:43 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6N4dh0A026519
	for <netdev@vger.kernel.org>; Mon, 23 Jul 2007 00:39:43 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6N4dhr0256320
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 22:39:43 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6N4dgSc002550
	for <netdev@vger.kernel.org>; Sun, 22 Jul 2007 22:39:43 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

According to the RFC 4292 (IP Forwarding Table MIB) there is a need for an age entry for all the routes in therouting table. The entry in the RFC is inetCidrRouteAge and oid is inetCidrRouteAge.1.10.
Many snmp application require this age entry. So iam adding the age field in the routing table for ipv4 and ipv6 and providing the interface for this value netlink.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---

