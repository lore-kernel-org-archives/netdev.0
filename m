From: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Subject: [PATCH 0/4 Rev-3] Age Entry For IPv4 & IPv6 Route Table
Date: Wed, 29 Aug 2007 12:28:41 +0530
Message-ID: <20070829122841.5166e94e.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, socketcan@hartkopp.net,
	shemminger@linux-foundation.org, krkumar2@in.ibm.com,
	tgraf@suug.ch, varuncha@in.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:40187 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985AbXH2G6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 02:58:07 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7T6vuVN027039
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 02:57:56 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7T6vuPQ504408
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 00:57:56 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7T6vtHg015229
	for <netdev@vger.kernel.org>; Wed, 29 Aug 2007 00:57:56 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,
	The is the next revision of the age patch. This contains changes as suggested in the last rev.
Can you review and push it in? I also added the changelog below.

Original Comment:
According to the RFC 4292 (IP Forwarding Table MIB) there is a need for an age entry for all the routes in therouting table. The entry in the RFC is inetCidrRouteAge and oid is inetCidrRouteAge.1.10.
Many snmp application require this age entry. So iam adding the age field in the routing table for ipv4 and ipv6 and providing the interface for this value netlink.

I made a note of changes i made as per the suggestions given in the community. Here is the changelog.

Changelog since ver 1:
---------------------
        Changes							Suggestion	
 
1)Change in the interface from proc to netlink.
  It was not approved by David Miller and Yoshifuji.            David Miller & Yoshifuji

2)Change from jiffies to timeval.				Eric Dumazet

3)Rounding up timeval						Patrick McHardy, Oliver Hartkopp
								Eric Dumazet.

4)Relocate timeval_to_sec					Stephen Hemminger, Krishna Kumar

5)Using macro RT6_GET_ROUTE_INFO				Krishna Kumar

6)Add proper comment for timeval_to_sec				Eric Dumazet

7)Add proper comment for timeval insertion			Thomas Graf				  

Signed-off-by: Varun Chandramohan <varunc@linux.vnet.ibm.com>
---

