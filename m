From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 0/4 - rev 2] Age Entry For IPv4 & IPv6 Route Table
Date: Mon, 20 Aug 2007 13:43:29 +0530
Message-ID: <20070820134329.1590be39.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com,
	varuncha@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49105 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbXHTIM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 04:12:56 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7K8CtHq010052
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 04:12:55 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7K8CtlI203172
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 02:12:55 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7K8CsA2030718
	for <netdev@vger.kernel.org>; Mon, 20 Aug 2007 02:12:55 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,
         This is rev2 of the patch set i sent out sometime ago. I have made it against net-2.6.24 tree. Can you please review and let me know? There have been a few minor changes since rev1.

Original Message:
According to the RFC 4292 (IP Forwarding Table MIB) there is a need for an age entry for all the routes in therouting table. The entry in the RFC is inetCidrRouteAge and oid is inetCidrRouteAge.1.10.
Many snmp application require this age entry. So iam adding the age field in the routing table for ipv4 and ipv6 and providing the interface for this value netlink.

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---

