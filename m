From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Wed, 21 Feb 2007 11:56:08 +0300
Message-ID: <20070221085608.GC1903@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <200702201738.19590.dada1@cosmosbay.com> <20070220165907.GB24930@2ka.mipt.ru> <200702201820.27095.dada1@cosmosbay.com> <20070220175550.GB26961@2ka.mipt.ru> <20070220181217.GA3401@2ka.mipt.ru> <f2b55d220702201113m12355e5ds584cede246d4728c@mail.gmail.com> <20070220194409.GB5590@2ka.mipt.ru> <f2b55d220702201203m2f188253h7f68d5be9a457f4a@mail.gmail.com> <f2b55d220702201209m6d6a276fj75f3462cdf6daeb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, akepner@sgi.com,
	linux@horizon.com, netdev@vger.kernel.org, bcrl@kvack.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42187 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161143AbXBUI5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 03:57:23 -0500
Content-Disposition: inline
In-Reply-To: <f2b55d220702201209m6d6a276fj75f3462cdf6daeb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 12:09:59PM -0800, Michael K. Edwards (medwards.linux@gmail.com) wrote:
> On 2/20/07, Michael K. Edwards <medwards.linux@gmail.com> wrote:
> >Correct.  That's called a "weak hash", and Jenkins is known to be a
> >thoroughly weak hash.  That's why you never, ever use it without a
> >salt, and you don't let an attacker inspect the hash output either.
> 
> Weak in a cryptographic sense, of course.  Excellent avalanche
> behavior, though, which is what you care about in a salted hash.
> http://en.wikipedia.org/wiki/Hash_table

I repeat again - add your salt into jenkins hash and I will show you
that it has the same problems.
So, I'm waiting for your patch for jhash_*_words().

> I know nothing about data structures and algorithms except what I read
> on the Internet.  But you'd be amazed what's on the Internet.
> 
> Cheers,
> - Michael

-- 
	Evgeniy Polyakov
