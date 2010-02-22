From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] packet: convert socket list to RCU (v3)
Date: Mon, 22 Feb 2010 15:46:19 -0800 (PST)
Message-ID: <20100222.154619.21200458.davem@davemloft.net>
References: <20100222175716.900955428@vyatta.com>
	<20100222175742.681962290@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47057
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750953Ab0BVXqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2010 18:46:01 -0500
In-Reply-To: <20100222175742.681962290@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 22 Feb 2010 09:57:18 -0800

> Convert AF_PACKET to use RCU, eliminating one more reader/writer lock.
> 
> There is no need for a real sk_del_node_init_rcu(), because sk_del_node_init
> is doing the equivalent thing to hlst_del_init_rcu already; but added
> some comments to try and make that obvious.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
