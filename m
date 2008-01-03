From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 3 Jan 2008 11:15:34 -0500
Message-ID: <200801031115.34886.paul.moore@hp.com>
References: <20080103095829.GB2000@ff.dom.local> <1199359402.4710.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>
To: hadi@cyberus.ca, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:40409 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751720AbYACQPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 11:15:40 -0500
In-Reply-To: <1199359402.4710.17.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 January 2008 6:23:22 am jamal wrote:
> On Thu, 2008-03-01 at 10:58 +0100, Jarek Poplawski wrote:
> > On 02-01-2008 17:01, Paul Moore wrote:
> > > This patch is needed by some of the labeled networking changes
> > > proposed for 2.6.25, does anyone have any objections?
> >
> > Probably Jamal could be the most interested (added to CC):
>
> Gracias Jarek.
> Paul, (out of curiosity more than anything) what are the
> circumstances of the cloned skb - are you going to reinject it back
> at some point?
>
> I cant think of any good reason why iif shouldnt be copied - thats
> how its been from the begining (dammit;->). The reason it hasnt
> mattered so far is everything that needs to write the iif never
> copied (refer to Documentation/networking/tc-actions-env-rules.txt).
> For correctness i think it should be copied. So no objections;
> The better patch would be to just put it in skb_clone and remove it
> from tc_act_clone.

While I'm at it, is there some reason for this #define in __skb_clone()?

 #define C(x) n->x = skb->x

... it seems kinda silly to me and I tend to think the code would be 
better without it.

-- 
paul moore
linux security @ hp
