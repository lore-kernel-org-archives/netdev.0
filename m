From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] NET: Clone the sk_buff->iif field properly
Date: Thu, 3 Jan 2008 22:13:12 +0100
Message-ID: <20080103211312.GA7258@ami.dom.local>
References: <20080103095829.GB2000@ff.dom.local> <1199359402.4710.17.camel@localhost> <200801031115.34886.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:2530 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752155AbYACVKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 16:10:19 -0500
Received: by nf-out-0910.google.com with SMTP id g13so441278nfb.21
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2008 13:10:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <200801031115.34886.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 03, 2008 at 11:15:34AM -0500, Paul Moore wrote:
...
> While I'm at it, is there some reason for this #define in __skb_clone()?
> 
>  #define C(x) n->x = skb->x
> 
> ... it seems kinda silly to me and I tend to think the code would be 
> better without it.

IMHO, if there are a lot of this, it's definitely more readable: easier
to check which values are simply copied and which need something more.
But, as usual, it's probably a question of taste, and of course without
it it would definitely look classier...

Cheers,
Jarek P.

PS: I hope you didn't suggest earlier my (better?) knowlege of git;
otherwise don't bother: with your git push you are far ahead of my
gitweb 'degree'.
