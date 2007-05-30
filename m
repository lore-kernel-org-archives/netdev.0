From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 30 May 2007 12:10:01 -0400
Message-ID: <1180541401.4109.72.camel@localhost>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
	 <1180536987.4109.19.camel@localhost>  <465D97F1.9090600@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:41572 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752891AbXE3QKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 12:10:08 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1812008wxc
        for <netdev@vger.kernel.org>; Wed, 30 May 2007 09:10:04 -0700 (PDT)
In-Reply-To: <465D97F1.9090600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-30-05 at 17:27 +0200, Patrick McHardy wrote:
> jamal wrote:

> Sure. The thing I don't like about the predefined hash functions is
> that its unflexible.
> 

agreed.

> > skb->prio as a selector. I think if you removed that it should be fine.
>
> I don't think thats a problem, it needs to point to the correct major
> to have any effect, which can only happen if it is set by the user.
> I would prefer to keep it for consistency with other qdiscs.
> 
> > Another alternative is to create a brand new FQ qdisc and leave the
> > classification to the classifiers.
>
> I created a new classifier to leave classification to the classifiers ..
> Not sure exactly why I would need a new qdisc to do that :)
> 

The caveat/difference with current SFQ is you have allowed the user to
define which queue is selected. It is/was dynamically selected based on
packet header now/before. Thats the main reason i said maybe you
separate the two components totaly. i.e while FQ is useful on its own
and can use other classifiers; a useful classifier IMO for SFQ is one
that rips out the sfq_hash or whatever other schemes used in ESFQ into a
classifier (I suppose then the user can select which hash is used). In
such a classifier you can restore the pertub into it.
I am not sure i made sense.

> > I am almost tempted to say go back and write a qdisc called FQ.
> 
> 
> Funny, last the this came up you suggested to do basically exactly
> what this classifier does, which I thought made sense :)
> 
> http://www.mail-archive.com/netdev@vger.kernel.org/msg06801.html

I am almost sensing i am contradicting myself in that thread;-> It is
hard to tell and i admit to being forgetful - but what i probably meant
is what i said above. 

cheers,
jamal

