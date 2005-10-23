From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [0/3] Fix timer bugs in neighbour cache
Date: Sun, 23 Oct 2005 17:30:21 +1000
Message-ID: <E1ETaJB-0004a0-00@gondolin.me.apana.org.au>
References: <43534273.2050106@reub.net>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, acme@conectiva.com.br, davem@davemloft.net,
	greearb@candelatech.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751422AbVJWHar@vger.kernel.org>
To: reuben-lkml@reub.net (Reuben Farrelly)
In-Reply-To: <43534273.2050106@reub.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Reuben Farrelly <reuben-lkml@reub.net> wrote:
> 
> Oct 17 18:49:40 tornado kernel: NEIGH: BUG, double timer add, state is 1
> Oct 17 18:51:04 tornado last message repeated 3 times
> Oct 17 18:52:05 tornado last message repeated 5 times
> Oct 17 18:52:11 tornado last message repeated 2 times

Excellent.  Looks like we actually caught something.  Pity we don't have
a stack trace which means that there might be more bugs.

Anyway, here are three patches which should fix this.  This should go
into 2.6.14.

Arnaldo, you can pull them from

master.kernel.org:/pub/scm/linux/kernel/git/herbert/net-2.6.git

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
