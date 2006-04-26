From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: determine outgoing interface (eth0,eth1) for a packet according to the dest IP
Date: Wed, 26 Apr 2006 23:58:00 +1000
Message-ID: <E1FYkWm-0003MM-00@gondolin.me.apana.org.au>
References: <ada605fb0604260324n4dc99556j300bfd433a9027d9@mail.gmail.com>
Cc: ak@suse.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56848 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932453AbWDZN6H
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 09:58:07 -0400
To: qwejohn@gmail.com (John Que)
In-Reply-To: <ada605fb0604260324n4dc99556j300bfd433a9027d9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John Que <qwejohn@gmail.com> wrote:
> 
> I had spent time trying to write something which
> uses RTA_SRC and RTA_DST and got some problems.
> (I probably made something stupid.)
> I googled for such examples and did not get much.
> I saw that the zebra project and iproute uses
> netlinks but it is complex.,

Have a look at

http://gondor.apana.org.au/~herbert/findsaddr-linux.c

which I wrote for traceroute some years back.  It should be easy
to adapt to get the interface instead of the source address.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
