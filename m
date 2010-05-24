From: David Miller <davem@davemloft.net>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Sun, 23 May 2010 23:44:20 -0700 (PDT)
Message-ID: <20100523.234420.214015782.davem@davemloft.net>
References: <20100521003939.GA2223@localhost.localdomain>
	<20100521010211.GA23671@gondor.apana.org.au>
	<20100521011632.GA23849@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, eric.dumazet@gmail.com, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@redhat.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42467
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753654Ab0EXGoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 02:44:10 -0400
In-Reply-To: <20100521011632.GA23849@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 21 May 2010 11:16:32 +1000

> tun: Update classid on packet injection
> 
> This patch makes tun update its socket classid every time we
> inject a packet into the network stack.  This is so that any
> updates made by the admin to the process writing packets to
> tun is effected.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
