From: "Michael K. Edwards" <medwards.linux@gmail.com>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 12:03:04 -0800
Message-ID: <f2b55d220702201203m2f188253h7f68d5be9a457f4a@mail.gmail.com>
References: <200702191913.08125.dada1@cosmosbay.com>
	 <200702201738.19590.dada1@cosmosbay.com>
	 <20070220165907.GB24930@2ka.mipt.ru>
	 <200702201820.27095.dada1@cosmosbay.com>
	 <20070220175550.GB26961@2ka.mipt.ru>
	 <20070220181217.GA3401@2ka.mipt.ru>
	 <f2b55d220702201113m12355e5ds584cede246d4728c@mail.gmail.com>
	 <20070220194409.GB5590@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>,
	"David Miller" <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.225]:10038 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965195AbXBTUDF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 15:03:05 -0500
Received: by nz-out-0506.google.com with SMTP id s1so2033423nze
        for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 12:03:04 -0800 (PST)
In-Reply-To: <20070220194409.GB5590@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/20/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> How I like personal insults - it is always fun to read about myself from
> people who never knew me :)

On this occasion, I did not set out to insult you.  I set out to
suggest an explanation for why cooler and grayer heads than mine are
not falling over themselves to merge your designs into the mainline
kernel.  Did I succeed?

> I just shown a problem in jenkins hash - it is not how to find a
> differnet input for the same output - it is a _law_ which allows to
> break a hash. You will add some constant, and that law will be turned
> into something different (getting into account what was written, it will
> end up with the same law).

Correct.  That's called a "weak hash", and Jenkins is known to be a
thoroughly weak hash.  That's why you never, ever use it without a
salt, and you don't let an attacker inspect the hash output either.

> Using jenkins hash is equal to the situation, when part of you hash
> chains will be 5 times longer than median square value, with XOR one
> there is no such distribution.

Show us the numbers.  Salt properly this time to reduce the artifacts
that come of applying a weak hash to a poor PRNG, and histogram your
results.  If you don't get a Poisson distribution you probably don't
know how to use gnuplot either.  :-)

> Added somthing into permutations will not endup in different
> distribution, since it is permutations which are broken, not its result
> (which can be xored with something).

I can't parse this.  Care to try again?

Cheers,
- Michael
