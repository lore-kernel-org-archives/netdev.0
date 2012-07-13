From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add LAST_ACK as a valid state for TSQ
Date: Fri, 13 Jul 2012 02:59:50 -0700 (PDT)
Message-ID: <20120713.025950.672725648061707733.davem@davemloft.net>
References: <1342169169.3265.8338.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, mattmathis@google.com,
	maheshb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39796 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757109Ab2GMJ7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 05:59:51 -0400
In-Reply-To: <1342169169.3265.8338.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Jul 2012 10:46:09 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Socket state LAST_ACK should allow TSQ to send additional frames,
> or else we rely on incoming ACKS or timers to send them.
> 
> Reported-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
