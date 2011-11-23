From: David Miller <davem@davemloft.net>
Subject: Re: Missing TCP SYN on loopback, retransmits after 1s
Date: Wed, 23 Nov 2011 17:29:59 -0500 (EST)
Message-ID: <20111123.172959.909786536317740314.davem@davemloft.net>
References: <20111122.192338.1206677511966747729.davem@davemloft.net>
	<20111122183727.01ab6f04@telperion.jlyo.org>
	<1322059124.17693.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jlyo@jlyo.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39537 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756304Ab1KWWaE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 17:30:04 -0500
In-Reply-To: <1322059124.17693.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Nov 2011 15:38:44 +0100

> [PATCH] ipv6: tcp: fix tcp_v6_conn_request()
> 
> Since linux 2.6.26 (commit c6aefafb7ec6 : Add IPv6 support to TCP SYN
> cookies), we can drop a SYN packet reusing a TIME_WAIT socket.
> 
> (As a matter of fact we fail to send the SYNACK answer)
> 
> As the client resends its SYN packet after a one second timeout, we
> accept it, because first packet removed the TIME_WAIT socket before
> being dropped.
> 
> This probably explains why nobody ever noticed or complained.
> 
> Reported-by: Jesse Young <jlyo@jlyo.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks!
