From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] veth: reduce stat overhead
Date: Sun, 30 Dec 2012 02:32:51 -0800 (PST)
Message-ID: <20121230.023251.2141803276451479121.davem@davemloft.net>
References: <1356832963.21409.6156.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab2L3Kcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 05:32:52 -0500
In-Reply-To: <1356832963.21409.6156.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 29 Dec 2012 18:02:43 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> veth stats are a bit bloated. There is no need to account transmit
> and receive stats, since they are absolutely symmetric.
> 
> Also use a per device atomic64_t for the dropped counter, as it
> should never be used in fast path.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
