From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Tue, 30 Mar 2010 22:44:39 -0700
Message-ID: <m1ljd982pk.fsf@fess.ebiederm.org>
References: <20100328082250.GA14053@gondor.apana.org.au>
	<20100328.055312.58421329.davem@davemloft.net>
	<20100328131112.GA15984@gondor.apana.org.au>
	<20100328.064012.193708716.davem@davemloft.net>
	<20100328135931.GA16430@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45744 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755243Ab0CaFon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 01:44:43 -0400
In-Reply-To: <20100328135931.GA16430@gondor.apana.org.au> (Herbert Xu's message of "Sun\, 28 Mar 2010 21\:59\:31 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:


> BTW, it appears that the inetpeer cache doesn't take namespaces
> into account.  This means that information could potentially leak
> from one namespace into another.  I'm not sure whether that's a
> big deal or not but it's something for the namespaces folks to
> consider.

Bother. I wrote a patch a while back, I even remember people
commenting on it, but it certainly doesn't look like anything
ever made it in.

I will see if I can make some time to dig that up and post
the patch.

Thanks for noticing,
Eric
