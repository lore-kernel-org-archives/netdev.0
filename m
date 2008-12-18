From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 20:06:18 +1100
Message-ID: <20081218090618.GA29096@gondor.apana.org.au>
References: <20081217103129.GA17248@gondor.apana.org.au> <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz> <20081217112600.GA19106@gondor.apana.org.au> <20081217114138.GA20976@gondor.apana.org.au> <20081217125505.GA8379@ms2.inr.ac.ru> <20081217153015.GA17903@ms2.inr.ac.ru> <1229529888.13305.57.camel@nathan.suse.cz> <20081217213052.GB27243@gondor.apana.org.au> <1229590692.12322.2.camel@nathan.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Petr Tesarik <ptesarik@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43927 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751457AbYLRJHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 04:07:14 -0500
Content-Disposition: inline
In-Reply-To: <1229590692.12322.2.camel@nathan.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 09:58:12AM +0100, Petr Tesarik wrote:
>
> That doesn't contradict my suggestion, which is: "Send the SIGURG as
> soon as possible, but do not send _more_ SIGURGs until the urgent data
> arrives."  I'm going to send a patch to make it clear.

OK that does make sense.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
