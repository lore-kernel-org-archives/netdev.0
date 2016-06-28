From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next] tcp: md5: use kmalloc() backed scratch areas
Date: Tue, 28 Jun 2016 11:41:50 +0800
Message-ID: <20160628034150.GA13953@gondor.apana.org.au>
References: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
 <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466829439.6850.126.camel@edumazet-glaptop3.roam.corp.google.com>
 <1466870975.6850.139.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467046313.6850.171.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:49111 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbcF1DmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 23:42:01 -0400
Content-Disposition: inline
In-Reply-To: <CALCETrUSi3T5JXMunEO9RM5ZEz=aA2xtf9encEVYGxJF4mbhKg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 10:58:42AM -0700, Andy Lutomirski wrote:
>
> I wonder if it's worth switching from ahash to shash, though.  It
> would probably be simpler and faster.

No shash is not appropriate here because it needs to hash skb
frags which are SG lists.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
