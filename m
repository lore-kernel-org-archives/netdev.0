From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] Age Entry For IPv4 Route Table
Date: Mon, 25 Jun 2007 16:10:14 +0200
Message-ID: <20070625161014.180cb972.dada1@cosmosbay.com>
References: <20070625102838.9d1fee20.varunc@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sri@us.ibm.com, dlstevens@us.ibm.com,
	varuncha@in.ibm.com
To: Varun Chandramohan <varunc@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:49584 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753045AbXFYOKQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2007 10:10:16 -0400
In-Reply-To: <20070625102838.9d1fee20.varunc@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Jun 2007 10:28:38 +0530
Varun Chandramohan <varunc@linux.vnet.ibm.com> wrote:

> According to the RFC 4292 (IP Forwarding Table MIB) there is a need for an age entry for all the routes in the routing table. The entry in the RFC is inetCidrRouteAge and oid is inetCidrRouteAge.1.10.
> Many snmp application require this age entry. So iam adding the age field in the routing table and providing
> the interface for this value via /proc/net/route.
> 

Hi Varun

If you find a way to expose this information without breaking /proc/net/route, please consider that jiffies can wrap
every 49 days on 32 bit platforms.
So you probably want to use an other time infrastructure if you want meaningfull Age information.
