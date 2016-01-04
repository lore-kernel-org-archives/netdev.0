From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] l2tp: rely on ppp layer for skb scrubbing
Date: Mon, 04 Jan 2016 16:45:59 -0500 (EST)
Message-ID: <20160104.164559.1746925711107907320.davem@davemloft.net>
References: <bdce354dbc9292208473f47486f7aa28f518b4fc.1451390671.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862AbcADVqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 16:46:00 -0500
In-Reply-To: <bdce354dbc9292208473f47486f7aa28f518b4fc.1451390671.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Tue, 29 Dec 2015 13:06:59 +0100

> Since 79c441ae505c ("ppp: implement x-netns support"), the PPP layer
> calls skb_scrub_packet() whenever the skb is received on the PPP
> device. Manually resetting packet meta-data in the L2TP layer is thus
> redundant.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied, thank you.
