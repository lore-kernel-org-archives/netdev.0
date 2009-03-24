From: Ingo Molnar <mingo@elte.hu>
Subject: Re: BUG in 2.6.29 final: broken network connection
Date: Tue, 24 Mar 2009 22:45:36 +0100
Message-ID: <20090324214536.GA29509@elte.hu>
References: <200903241812.14577.sinter.salt@gmx.de> <200903241918.29929.sinter.salt@gmx.de> <20090324194254.GB26930@elte.hu> <200903242149.59640.sinter.salt@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: sinter <sinter.salt@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:44707 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753160AbZCXVpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 17:45:51 -0400
Content-Disposition: inline
In-Reply-To: <200903242149.59640.sinter.salt@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* sinter <sinter.salt@gmx.de> wrote:

> > And there's an easy solution for you in any case: you can wait 
> > for .29.1 which i'm sure will be out quickly.
> 
> And what top-class advice would you give me if I would have found 
> that serious bug in .29.8 or in .29.9? Due to your answer every 
> shit is possible and nothing is impossible, or did I get something 
> wrong?

You got it exactly right.

This world is ruled by probabilities, and generally everything is 
possible - even a bug slipping into a .0 release that you could 
trigger personally, even though -rc1 through -rc8 worked just fine 
for you.

Such things happened before, and they can happen again. Yes, it can 
hit you - and it did hit me too and i'm not complaining.

We still try our best to reduce the probabilities. We cannot, 
however, unfortunately, bring them down to zero. The fix looked 
reasonable and the justification of it fixing a live crash looked 
reasonable too.

What we can do, and what we did do, was to provide people (you 
included) with a fix within 12 hours after the code having been 
released.

That's the deal really.

	Ingo
