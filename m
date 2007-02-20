From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 22:36:32 +0300
Message-ID: <20070220193632.GA5590@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <200702201955.15567.dada1@cosmosbay.com> <20070220190634.GA12193@2ka.mipt.ru> <200702202017.31965.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "Michael K. Edwards" <medwards.linux@gmail.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58160 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030375AbXBTTsC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 14:48:02 -0500
Content-Disposition: inline
In-Reply-To: <200702202017.31965.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 08:17:31PM +0100, Eric Dumazet (dada1@cosmosbay.com) wrote:
> I shown your test was bogus. All your claims are just bogus.
> I claim your 'true random data' is a joke. rand() in your program is a pure 
> joke.

Care to reread your mail about your true random case with hash chain
length of 3 and 4? Anyway, I just shown that jenkins hash is simple to
crack and to find its collisions - even if you will put there some
constant value it will be the same. It is math, not something special
speculation about input values.

> Given 48 bits of input, you *can* find a lot of addr/port to hit one 
> particular cache line if XOR function is used. With jhash, without knowing 
> the 32bits random secret, you *cant*.

You seems to do not want to understand that it is exactly the same as
searching for collision law. It is simple, and results will be
dangerous.

> Again, you dont take into account the chain length.
> 
> If all chains were of length <= 1, then yes, xor would be faster. In real 
> life, we *know* chain length can be larger, especially in DOS situations.

I.e. you propose to add a hash, which has broken case for the same ip
addresses and different ports compared to good xor?
It was shown that hash(const, const, non_const) ends up with _broken_
distribution comapred to xor hash.

-- 
	Evgeniy Polyakov
