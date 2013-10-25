From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] netpoll: fix rx_hook() interface by passing the
 skb
Date: Fri, 25 Oct 2013 19:27:22 -0400 (EDT)
Message-ID: <20131025.192722.2209080132367514630.davem@davemloft.net>
References: <20131023.161603.1190144528425577653.davem@davemloft.net>
	<1382564190-334-1-git-send-email-antonio@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David.Laight@ACULAB.COM
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36192 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075Ab3JYX1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 19:27:23 -0400
In-Reply-To: <1382564190-334-1-git-send-email-antonio@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Wed, 23 Oct 2013 23:36:30 +0200

> Right now skb->data is passed to rx_hook() even if the skb
> has not been linearised and without giving rx_hook() a way
> to linearise it.
> 
> Change the rx_hook() interface and make it accept the skb
> and the offset to the UDP payload as arguments. rx_hook() is
> also renamed to rx_skb_hook() to ensure that out of the tree
> users notice the API change.
> 
> In this way any rx_skb_hook() implementation can perform all
> the needed operations to properly (and safely) access the
> skb data.
> 
> Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>

Applied.
