From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 17:21:41 +0300
Message-ID: <20081217142141.GA27851@ms2.inr.ac.ru>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi> <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au> <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz> <20081217112600.GA19106@gondor.apana.org.au> <20081217114138.GA20976@gondor.apana.org.au> <20081217125505.GA8379@ms2.inr.ac.ru> <1229520685.13305.32.camel@nathan.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Petr Tesarik <ptesarik@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:36585 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750721AbYLQO2q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 09:28:46 -0500
Content-Disposition: inline
In-Reply-To: <1229520685.13305.32.camel@nathan.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

> This might turn out to be a dangerous decision. I am aware at least of
> one big application which uses urgent data and doesn't use SO_OOBINLINE:
> Oracle.

Yes, this is not some "rlogin"...


> Yes, of course it's broken, but do we really want to join the much-hated
> folks who are stuck with an only-we-do-it-correctly approach?

Well, we do not want to return to that company. :-)

