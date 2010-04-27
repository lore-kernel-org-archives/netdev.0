From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: set skb->rxhash
Date: Tue, 27 Apr 2010 15:43:38 -0700 (PDT)
Message-ID: <20100427.154338.223483726.davem@davemloft.net>
References: <1272406825-11615-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46798
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755121Ab0D0Wne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:43:34 -0400
In-Reply-To: <1272406825-11615-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Tue, 27 Apr 2010 15:20:25 -0700

> Implement the ->set_flags ethtool method to control NETIF_F_RXHASH and
> set skb->rxhash to the HW calculated hash accordingly.
> 
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

Does the CXGB4 hash the ports for non-TCP packets?

If not, you will need to check the packet type (preferrably using
RX descriptor information rather than actually parsing the packet)
and only record the ->rxhash for TCP packets.

