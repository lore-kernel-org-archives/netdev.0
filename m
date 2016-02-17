From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] pppoe: fix reference counting in PPPoE proxy
Date: Wed, 17 Feb 2016 16:03:13 -0500 (EST)
Message-ID: <20160217.160313.2285933128016667199.davem@davemloft.net>
References: <20160215160110.GA1186@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57649 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161042AbcBQVDP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 16:03:15 -0500
In-Reply-To: <20160215160110.GA1186@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Mon, 15 Feb 2016 17:01:10 +0100

> Drop reference on the relay_po socket when __pppoe_xmit() succeeds.
> This is already handled correctly in the error path.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> ---
> No 'Fixes' tag, since this issue seems to predate git's history.

Hard to believe that such an obvious leak has existed for so long.

Applied, and queued up for -stable, thanks!
