From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net] ipv6: lock socket in ip6_datagram_connect()
Date: Tue, 14 Jul 2015 15:56:32 +0800
Message-ID: <20150714075632.GA21140@gondor.apana.org.au>
References: <1436854222.1374.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:58056 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbbGNH4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 03:56:38 -0400
Content-Disposition: inline
In-Reply-To: <1436854222.1374.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> ip6_datagram_connect() is doing a lot of socket changes without
> socket being locked.
> 
> This looks wrong, at least for udp_lib_rehash() which could corrupt
> lists because of concurrent udp_sk(sk)->udp_portaddr_hash accesses.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Good find! This goes all the way back to 1.3 it seems :)

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
