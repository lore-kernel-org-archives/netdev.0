From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: fix link down handling in 802.3ad mode
Date: Sun, 17 May 2009 21:16:05 -0700 (PDT)
Message-ID: <20090517.211605.119521245.davem@davemloft.net>
References: <20090515114432.4025a2d6@nehalam>
	<12527.1242416155@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, bonding-devel@lists.sf.net,
	netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36508
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751127AbZEREQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 00:16:07 -0400
In-Reply-To: <12527.1242416155@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 15 May 2009 12:35:55 -0700

> Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
>>One of the purposes of bonding is to allow for redundant links, and failover 
>>correctly if the cable is pulled. If all the members of a bonded device have
>>no carrier present, the bonded device itself needs to report no carrier present
>>to user space so management tools (like routing daemons) can respond.
>>
>>Bonding in 802.3ad mode does not work correctly for this because it incorrectly 
>>chooses a link that is down as a possible aggregator.
>>
>>Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 	Looks good.  I tested this after putting some printks in the agg
> selection logic, and I don't see any undesirable side effects.
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied, thanks everyone.
