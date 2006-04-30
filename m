From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: determine outgoing interface (eth0,eth1) for a packet according to the dest IP
Date: Sun, 30 Apr 2006 22:55:39 +1000
Message-ID: <20060430125539.GA11977@gondor.apana.org.au>
References: <ada605fb0604260324n4dc99556j300bfd433a9027d9@mail.gmail.com> <E1FYkWm-0003MM-00@gondolin.me.apana.org.au> <20060430091711.GL24458@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Que <qwejohn@gmail.com>, ak@suse.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:10248 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751106AbWD3Mzx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Apr 2006 08:55:53 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
Content-Disposition: inline
In-Reply-To: <20060430091711.GL24458@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Apr 30, 2006 at 11:17:11AM +0200, Lennert Buytenhek wrote:
> 
> A fragile and ugly but easier/shorter way of getting the source address
> (which I've used a couple of times in the past) is to open a SOCK_DGRAM
> socket, connect() it to the intended destination, and then do
> getsockname().

Yes you're quite right that this would've been a much simpler solution.
I suppose I was quite fond of the netlink hammer at the time :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
