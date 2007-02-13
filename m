From: Baruch Even <baruch@ev-en.org>
Subject: Re: [patch 3/3] tcp: remove experimental variants from default list
Date: Tue, 13 Feb 2007 11:56:13 +0200
Message-ID: <20070213095613.GR25760@galon.ev-en.org>
References: <20070212191101.GP25760@galon.ev-en.org> <20070212.122058.63127043.davem@davemloft.net> <20070212221241.GQ25760@galon.ev-en.org> <20070212.145351.35661569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:63379
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbXBMJ4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 04:56:16 -0500
Content-Disposition: inline
In-Reply-To: <20070212.145351.35661569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [070213 00:53]:
> From: Baruch Even <baruch@ev-en.org>
> Date: Tue, 13 Feb 2007 00:12:41 +0200
> 
> > The problem is that you actually put a mostly untested algorithm as the
> > default for everyone to use. The BIC example is important, it was the
> > default algorithm for a long while and had implementation bugs that no
> > one cared for.
> 
> And if our TCP Reno implementation had some bugs, what should
> we change the default to?  This is just idiotic logic.
> 
> These kinds of comments are just wanking, and lead to nowhere,
> so please kill the noise.
> 
> If we have bugs in a particular algorithm, we should just fix
> them.

I hope you've finished attempting to insult me. But I hope it won't
prevent you from getting back to the topic. The above quote of me was a
prelude to show the repeat behaviour where bic was added without
testing, modified by Stephen and made default with no serious testing of
what was put in the kernel.

It seems this happens again no with cubic. And you failed to respond to
this issue.

> > The behaviour of cubic wasn't properly verified as the
> > algorithm in the linux kernel is not the one that was actually proposed
> > and you intend to make it the default without sufficient testing, that
> > seems to me to be quite unreasonable.

According to claims of Doug Leith the cubic algorithm that is in the
kernel is different from what was proposed and tested. That's an
important issue which is deflected by personal attacks.

My main gripe is that there is a run to make an untested algorithm the
default for all Linux installations. And saying that I should test it is
not an escape route, if it's untested it shouldn't be made the default
algorithm.

My skimming of the PFLDNet 2007 proceedings showed only the works by
Injong and Doug on Cubic and Injong tested some version on Linux
2.6.13(!) which might noe be the version in the current tree. Doug shows
some weaknesses of the Cubic algorithm as implemented in Linux.

Do you still think that making Cubic the default is a good idea?

Baruch
