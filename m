From: jamal <hadi@cyberus.ca>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Sun, 31 May 2009 09:17:10 -0400
Message-ID: <1243775830.3966.231.camel@dogo.mojatatu.com>
References: <20090530114506.GA3166@ami.dom.local>
	 <1243684594.3966.89.camel@dogo.mojatatu.com>
	 <20090530120750.GB3166@ami.dom.local>
	 <1243686683.3966.117.camel@dogo.mojatatu.com>
	 <20090530124554.GC3166@ami.dom.local>
	 <1243688628.3966.126.camel@dogo.mojatatu.com>
	 <20090530132047.GD3166@ami.dom.local>
	 <1243690297.3966.135.camel@dogo.mojatatu.com>
	 <20090530140006.GE3166@ami.dom.local>
	 <1243724933.3966.158.camel@dogo.mojatatu.com>
	 <20090531075528.GA2756@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Minoru Usui <mi.usui@gmail.com>,
	Minoru Usui <usui@mxm.nes.nec.co.jp>, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f130.google.com ([209.85.221.130]:45810 "EHLO
	mail-qy0-f130.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754008AbZEaNSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2009 09:18:10 -0400
Received: by qyk36 with SMTP id 36so951602qyk.33
        for <netdev@vger.kernel.org>; Sun, 31 May 2009 06:18:10 -0700 (PDT)
In-Reply-To: <20090531075528.GA2756@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-05-31 at 09:55 +0200, Jarek Poplawski wrote:

> Sure, after fixing it properly we should get rid of unneeded checks.

> > > Anyway, it's worked for other classifiers like this for some time...
> > 
> > Would you agree that it is/was a bandaid?
> > Or maybe you have some other fear that this may break something else and
> > prefer the workaround instead?
> 
> If somebody decided to do it this way instead of the "proper" fix then
> it looks to me more like a bandaid "by design". 

I think your and my definition of "proper" are at odds here ;->
My logic says there's a causality effect and you always fix the cause
in such a situation. 
Here's the anology of our conversation (some captured above) as i see it
centred around a bug of leaky pipe which just messed up the carpet
overnight in some room:
 
handyman Jamal: fix the pipe so it doesnt leak.
handyman Jarek: put a little bucket below the dripping spot
handyman Jamal: fixing this pipe is cheap - it is on warranty too
handyman Jarek: I fixed two other rooms by putting buckets
handyman Jamal: Proper: fix the pipe - you dont need the buckets forever
handyman Jarek: Proper fix is to put the bucket below any drip

Of course i am exagerating to make a point on our logical approaches:
leaking pipes dont quiet match software bugs i.e.
a dripping pipe will have the short term sense of emergency of needing
buckets but in this case the cost of the damage and time is the same
if you put a bucket or fixed the pipe.

> And, yes, I have some
> fear we could break some strange configs, which could depend on this
> wrong but working design.

To continue our discussion
handyman Jamal: What is your fear about fixing the pipe?
handyman Jarek: Someone may have plants which depend on the drips;
so if you fix it his plants wont get water anymore.

I hope the above doesnt offend you - it is meant in good spirit.

cheers,
jamal

