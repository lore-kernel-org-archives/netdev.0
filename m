From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPv6] SNMP: Increment OutNoRoutes when connecting to
 unreachable network
Date: Wed, 05 Dec 2007 22:32:12 -0800 (PST)
Message-ID: <20071205.223212.60067994.davem@davemloft.net>
References: <20071206152948.1f593cd5.mitch@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mitch@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54745
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752594AbXLFGcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 01:32:14 -0500
In-Reply-To: <20071206152948.1f593cd5.mitch@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitsuru Chinen <mitch@linux.vnet.ibm.com>
Date: Thu, 6 Dec 2007 15:29:48 +0900

> IPv6 stack doesn't increment OutNoRoutes counter when IP datagrams
> is being discarded because no route could be found to transmit them
> to their destination. IPv6 stack should increment the counter.
> Incidentally, IPv4 stack increments that counter in such situation.
> 
> Signed-off-by: Mitsuru Chinen <mitch@linux.vnet.ibm.com>

Patch applied, thanks!
