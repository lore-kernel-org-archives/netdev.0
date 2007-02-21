From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Wed, 21 Feb 2007 11:54:06 +0300
Message-ID: <20070221085406.GB1903@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <200702201738.19590.dada1@cosmosbay.com> <20070220165907.GB24930@2ka.mipt.ru> <200702201820.27095.dada1@cosmosbay.com> <20070220175550.GB26961@2ka.mipt.ru> <20070220181217.GA3401@2ka.mipt.ru> <f2b55d220702201113m12355e5ds584cede246d4728c@mail.gmail.com> <20070220194409.GB5590@2ka.mipt.ru> <f2b55d220702201203m2f188253h7f68d5be9a457f4a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42178 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161136AbXBUIzs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 03:55:48 -0500
Content-Disposition: inline
In-Reply-To: <f2b55d220702201203m2f188253h7f68d5be9a457f4a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 12:03:04PM -0800, Michael K. Edwards (medwards.linux@gmail.com) wrote:
> >I just shown a problem in jenkins hash - it is not how to find a
> >differnet input for the same output - it is a _law_ which allows to
> >break a hash. You will add some constant, and that law will be turned
> >into something different (getting into account what was written, it will
> >end up with the same law).
> 
> Correct.  That's called a "weak hash", and Jenkins is known to be a
> thoroughly weak hash.  That's why you never, ever use it without a
> salt, and you don't let an attacker inspect the hash output either.

Again, where will be your salt?
I'm going to show you that having constant xor on fairly distributed
system will not change distribution as long as bad one.

> >Using jenkins hash is equal to the situation, when part of you hash
> >chains will be 5 times longer than median square value, with XOR one
> >there is no such distribution.
> 
> Show us the numbers.  Salt properly this time to reduce the artifacts
> that come of applying a weak hash to a poor PRNG, and histogram your
> results.  If you don't get a Poisson distribution you probably don't
> know how to use gnuplot either.  :-)

I shown that numbers 4 times already, do you read mails and links?
Did you see an artifact Eric showed with his data?

> >Added somthing into permutations will not endup in different
> >distribution, since it is permutations which are broken, not its result
> >(which can be xored with something).
> 
> I can't parse this.  Care to try again?

Whre are you going to add a salt into jenkins hash to fix its
distribution?

In other words - jenkins hash is equal to simple shift - it is a hash
too, and it has bad distribution too, where will added salt ever help in
that scenario?

> Cheers,
> - Michael

-- 
	Evgeniy Polyakov
