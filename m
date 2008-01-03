From: Paul Moore <paul.moore@hp.com>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 3 Jan 2008 16:20:06 -0500
Message-ID: <200801031620.06603.paul.moore@hp.com>
References: <20080103095829.GB2000@ff.dom.local> <200801031115.34886.paul.moore@hp.com> <20080103211312.GA7258@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:14308 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226AbYACVUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 16:20:13 -0500
In-Reply-To: <20080103211312.GA7258@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 03 January 2008 4:13:12 pm Jarek Poplawski wrote:
> On Thu, Jan 03, 2008 at 11:15:34AM -0500, Paul Moore wrote:
> ...
>
> > While I'm at it, is there some reason for this #define in
> > __skb_clone()?
> >
> >  #define C(x) n->x = skb->x
> >
> > ... it seems kinda silly to me and I tend to think the code would
> > be better without it.
>
> IMHO, if there are a lot of this, it's definitely more readable:
> easier to check which values are simply copied and which need
> something more. But, as usual, it's probably a question of taste, and
> of course without it it would definitely look classier...

For me personally, I would argue the readability bit.  Whenever I see a 
function/macro call I have to go find the function/macro definition 
before I can understand what it is doing.  Granted, the macro is 
defined "local" to the function but my point is that being able to look 
at a line of code and understand it without having to look elsewhere is 
a nice quality.  To loose that simply because someone wants to save a 
few keystrokes is a mistake from my point of view.

Besides, if we are really interested in writing a kernel with the least 
number of keystrokes possible wouldn't we be doing it in perl?  I'm 
sure somebody out there has ported the current kernel source to a 
single line of perl ... ;)

> PS: I hope you didn't suggest earlier my (better?) knowlege of git;
> otherwise don't bother: with your git push you are far ahead of my
> gitweb 'degree'.

 ;)

On a serious note, your comment about gitweb made me poke around with 
some of the extra little features ... that 'history' link for each file 
is pretty cool!

-- 
paul moore
linux security @ hp
