From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inetpeer: lower false sharing effect
Date: Thu, 09 Jun 2011 20:43:30 -0700 (PDT)
Message-ID: <20110609.204330.2090335955971650557.davem@davemloft.net>
References: <1307600810.3980.85.camel@edumazet-laptop>
	<1307664235.17300.44.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, andi@firstfloor.org
To: tim.c.chen@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53221 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326Ab1FJDnj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 23:43:39 -0400
In-Reply-To: <1307664235.17300.44.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Thu, 09 Jun 2011 17:03:55 -0700

> When I retest with original 3.0-rc2 kernel, inet_putpeer no longer shows
> up, wonder if dst->peer was not set for some reason. 

The overhead will only show up if an inetpeer entry exists for
the destination IP address.

You can force one to be created, for example, by making a TCP
connection to that destination.
