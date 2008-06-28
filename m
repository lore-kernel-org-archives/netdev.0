From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net/inet_lro: remove setting skb->ip_summed when
 not LRO-able
Date: Fri, 27 Jun 2008 20:09:14 -0700 (PDT)
Message-ID: <20080627.200914.146689237.davem@davemloft.net>
References: <1214407752.23583.69.camel@mtls03>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, THEMANN@de.ibm.com,
	general@lists.openfabrics.org, or.gerlitz@gmail.com,
	vlad@mellanox.co.il, rdreier@cisco.com
To: eli@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55725
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751328AbYF1DJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 23:09:15 -0400
In-Reply-To: <1214407752.23583.69.camel@mtls03>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@dev.mellanox.co.il>
Date: Wed, 25 Jun 2008 18:29:12 +0300

> When an SKB cannot be chained to a session, the current code attempts
> to "restore" its ip_summed field from lro_mgr->ip_summed. However,
> lro_mgr->ip_summed does not hold the original value; in fact, we'd
> better not touch skb->ip_summed since it is not modified by the code
> in the path leading to a failure to chain it.
> Also use a cleaer comment to the describe the ip_summed field of
> struct net_lro_mgr.
> 
> Issue raised by Or Gerlitz <ogerlitz@voltaire.com>
> 
> Signed-off-by: Eli Cohen <eli@mellanox.co.il>

Patch applied, thanks everyone.
