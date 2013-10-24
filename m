From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net] netpoll: fix rx_hook() interface by passing the
 skb
Date: Thu, 24 Oct 2013 13:53:55 -0400 (EDT)
Message-ID: <20131024.135355.1844857206132081782.davem@davemloft.net>
References: <20131023.161603.1190144528425577653.davem@davemloft.net>
	<1382564190-334-1-git-send-email-antonio@meshcoding.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B73A5@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: antonio@meshcoding.com, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754844Ab3JXRx6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 13:53:58 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73A5@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "David Laight" <David.Laight@ACULAB.COM>
Date: Thu, 24 Oct 2013 09:43:38 +0100

> From a code optimisation point of view you probably don't want to be
> calculating the source, offset and length early.
> It is quite likely that the local variables will have to be written
> to the stack (because of the function calls) - so it is almost
> certainly more efficient to calculate them just before the call.

But this change is being made from a bug prevention point of view,
we already we're already getting this code path wrong as-is.
