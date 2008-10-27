From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Error: an inet prefix is expected rather than "0/0".
Date: Mon, 27 Oct 2008 10:39:50 -0700
Message-ID: <20081027103950.7eba4fe1@extreme>
References: <alpine.LNX.1.10.0810082331010.13921@bizon.gios.gov.pl>
	<E1KpkSl-00087W-GB@gondolin.me.apana.org.au>
	<20081014104621.3c2ce4d3@extreme>
	<20081015014624.GA3251@gondor.apana.org.au>
	<m34p3door9.fsf@maximus.localdomain>
	<1224086831.3984.196.camel@achroite>
	<m3y70pn11c.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Krzysztof Oledzki <ole@ans.pl>, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44674 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750727AbYJ0Rjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2008 13:39:52 -0400
In-Reply-To: <m3y70pn11c.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 15 Oct 2008 20:52:47 +0200
Krzysztof Halasa <khc@pm.waw.pl> wrote:

> Ben Hutchings <bhutchings@solarflare.com> writes:
> 
> > It's a Berkeley extension which spread via BSD and its inet_aton()
> > function.  I don't believe it's specified in any RFC.
> 
> You may be right, I won't start searching now :-)
> Anyway it was like that for years and I guess we shouldn't change it
> (except perhaps for removing).
> 
> > No, a single number is treated by inet_aton() as a 32-bit address, so 10
> > is equivalent to 0.0.0.10.
> 
> Hmm, I remember some routes being used without a dot, as a single
> number, but OTOH you're right, it was also possible to ping
> 12345678. Perhaps 10 -> 10.0 was specific to something rather than
> used generally, I don't know.

I ended up putting in a version similar to the original code but with
more error checking so it would not accept 259.1 etc.
