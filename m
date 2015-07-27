From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix recv with flags MSG_WAITALL | MSG_PEEK
Date: Mon, 27 Jul 2015 01:07:18 -0700 (PDT)
Message-ID: <20150727.010718.1993487512103673653.davem@davemloft.net>
References: <20150724161925.GA12489@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rh-bugzilla@ensc.de, dan@censornet.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750910AbbG0IHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2015 04:07:19 -0400
In-Reply-To: <20150724161925.GA12489@bistromath.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri, 24 Jul 2015 18:19:25 +0200

> Currently, tcp_recvmsg enters a busy loop in sk_wait_data if called
> with flags = MSG_WAITALL | MSG_PEEK.
> 
> sk_wait_data waits for sk_receive_queue not empty, but in this case,
> the receive queue is not empty, but does not contain any skb that we
> can use.
> 
> Add a "last skb seen on receive queue" argument to sk_wait_data, so
> that it sleeps until the receive queue has new skbs.
> 
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=99461
> Link: https://sourceware.org/bugzilla/show_bug.cgi?id=18493
> Link: https://bugzilla.redhat.com/show_bug.cgi?id=1205258
> Reported-by: Enrico Scholz <rh-bugzilla@ensc.de>
> Reported-by: Dan Searle <dan@censornet.com>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thanks.
