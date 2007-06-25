From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] Age Entry For IPv4 Route Table
Date: Mon, 25 Jun 2007 14:14:51 +0900 (JST)
Message-ID: <20070625.141451.21870598.yoshfuji@linux-ipv6.org>
References: <20070625102838.9d1fee20.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	varuncha@in.ibm.com, yoshfuji@linux-ipv6.org
To: varunc@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:42949 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380AbXFYFOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 01:14:30 -0400
In-Reply-To: <20070625102838.9d1fee20.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070625102838.9d1fee20.varunc@linux.vnet.ibm.com> (at Mon, 25 Jun 2007 10:28:38 +0530), Varun Chandramohan <varunc@linux.vnet.ibm.com> says:

> According to the RFC 4292 (IP Forwarding Table MIB) there is a need for an age entry for all the routes in the routing table. The entry in the RFC is inetCidrRouteAge and oid is inetCidrRouteAge.1.10.
> Many snmp application require this age entry. So iam adding the age field in the routing table and providing
> the interface for this value via /proc/net/route.

I'm not in favor of adding new field(s) to /proc/net/route.

--yoshfuji
