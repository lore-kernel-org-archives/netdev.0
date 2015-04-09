From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: do not rearm rsk_timer on FastOpen
 requests
Date: Wed, 08 Apr 2015 20:22:41 -0400 (EDT)
Message-ID: <20150408.202241.1719057759018638618.davem@davemloft.net>
References: <1428532444.25985.231.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42581 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754193AbbDIAWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 20:22:45 -0400
In-Reply-To: <1428532444.25985.231.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Apr 2015 15:34:04 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> FastOpen requests are not like other regular request sockets.
> 
> They do not yet use rsk_timer : tcp_fastopen_queue_check()
> simply manually removes one expired request from fastopenq->rskq_rst
> list.
> 
> Therefore, tcp_check_req() must not call mod_timer_pending(),
> otherwise we crash because rsk_timer was not initialized.
> 
> Fixes: fa76ce7328b ("inet: get rid of central tcp/dccp listener timer")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, thanks Eric.
