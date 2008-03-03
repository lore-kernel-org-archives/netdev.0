From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] race in generic address resolution
Date: Mon, 03 Mar 2008 12:16:29 -0800 (PST)
Message-ID: <20080303.121629.67950356.davem@davemloft.net>
References: <20080303131344.GA13659@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben.thery@gmail.com
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36164
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751484AbYCCUQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 15:16:45 -0500
In-Reply-To: <20080303131344.GA13659@tuxmaker.boeblingen.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Blaschka <frank.blaschka@de.ibm.com>
Date: Mon, 3 Mar 2008 14:13:44 +0100

> neigh_update sends skb from neigh->arp_queue while
> neigh_timer_handler has increased skbs refcount and calls
> solicit with the skb. neigh_timer_handler should not increase skbs
> refcount but make a copy of the skb and do solicit with the copy.
> 
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

Applied, thanks for following up on this Frank.
