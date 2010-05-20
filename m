From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Thu, 20 May 2010 07:15:07 +0200
Message-ID: <1274332507.2658.31.camel@edumazet-laptop>
References: <4BF4517F.1010206@athenacr.com>
	 <20100519.195533.22536631.davem@davemloft.net>
	 <20100520025741.GA6129@gondor.apana.org.au>
	 <20100519.200522.140743640.davem@davemloft.net>
	 <20100520033446.GA6434@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bmb@athenacr.com,
	tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44004 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425Ab0ETFPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 May 2010 01:15:13 -0400
Received: by wyg36 with SMTP id 36so1026794wyg.19
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 22:15:11 -0700 (PDT)
In-Reply-To: <20100520033446.GA6434@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 20 mai 2010 =C3=A0 13:34 +1000, Herbert Xu a =C3=A9crit :

> The value is set at socket creation time.  So all sockets created
> via socket(2) automatically gains the ID of the thread creating it.
> Now you may argue that this may not be the same as the thread that
> is sending the packet.  However, we already have a precedence where
> an fd is passed to a different thread, its security property is
> inherited.  In this case, inheriting the classid of the thread
> creating the socket is also the logical thing to do.

I find this very biased, sorry.

In fact, fd passing is just fine today, if we consider that we classify
packets using the identity of the process *using* the fd, not the one
that *created* it.

Now your patch changes this, to the reverse, and you justify the cachin=
g
effect on socket. Sorry, this must be too convoluted for me.




