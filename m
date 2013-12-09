From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 1/5] ipv6: add flowinfo for tcp6 pkt_options for all cases
Date: Tue, 10 Dec 2013 00:41:09 +0100
Message-ID: <20131209234109.GA7396@order.stressinduktion.org>
References: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43533 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707Ab3LIXlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 18:41:11 -0500
Content-Disposition: inline
In-Reply-To: <1386514021-11646-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 08, 2013 at 03:46:57PM +0100, Florent Fourcot wrote:
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

Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
