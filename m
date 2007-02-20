From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Extensible hashing and RCU
Date: Tue, 20 Feb 2007 18:59:28 +0300
Message-ID: <20070220155928.GA26600@2ka.mipt.ru>
References: <200702191913.08125.dada1@cosmosbay.com> <20070220092523.GA6238@2ka.mipt.ru> <200702201104.16200.dada1@cosmosbay.com> <20070220.021209.39159087.davem@davemloft.net> <f2b55d220702200707t605be092hf02a9ded1c98a264@mail.gmail.com> <20070220151119.GA17326@2ka.mipt.ru> <f2b55d220702200749l4fa2b14foa861cf37288cfb8d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	akepner@sgi.com, linux@horizon.com, netdev@vger.kernel.org,
	bcrl@kvack.org
To: "Michael K. Edwards" <medwards.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34064 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965190AbXBTQBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Feb 2007 11:01:31 -0500
Content-Disposition: inline
In-Reply-To: <f2b55d220702200749l4fa2b14foa861cf37288cfb8d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 20, 2007 at 07:49:11AM -0800, Michael K. Edwards (medwards.linux@gmail.com) wrote:
> On 2/20/07, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> >Jenkins _does_ have them, I showed tests half a year ago and in this
> >thread too. Actually _any_ hash has them it is just a matter of time
> >to find one.
> 
> I think you misunderstood me.  If you are trying to DoS me from
> outside with a hash collision attack, you are trying to feed me
> packets that fall into the same hash bucket.  The Jenkins hash does
> not have to be artifact-free, and does not have to be
> cryptographically strong.  It just has to do a passable job of mixing
> a random salt into the tuple, so you don't know which string of
> packets to feed me in order to fill one (or a few) of my buckets.
> XORing salt into a folded tuple doesn't help; it just permutes the
> buckets.

Adding XOR with constant value does not change distribution.
Variable salt will end up with differnet buckets for the same flow.
It is forbidden - it is not the situation created for passwd/des decades
ago.

> Cheers,
> - Michael

-- 
	Evgeniy Polyakov
