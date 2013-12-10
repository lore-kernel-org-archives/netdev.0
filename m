From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] ipv6: add flowinfo for tcp6 pkt_options
 for all cases
Date: Mon, 09 Dec 2013 21:04:07 -0500 (EST)
Message-ID: <20131209.210407.175864636691434095.davem@davemloft.net>
References: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: florent.fourcot@enst-bretagne.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45081 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887Ab3LJCEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:04:09 -0500
In-Reply-To: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Date: Sun,  8 Dec 2013 15:46:57 +0100

> The current implementation of IPV6_FLOWINFO only gives a
> result if pktoptions is available (thanks to the
> ip6_datagram_recv_ctl function).
> It gives inconsistent results to user space, sometimes
> there is a result for getsockopt(IPV6_FLOWINFO), sometimes
> not.
> 
> This patch add rcv_flowinfo to store it, and return it to
> the userspace in the same way than other pkt_options.
> 
> Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>

Applied.
