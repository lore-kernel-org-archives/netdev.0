From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Error: an inet prefix is expected rather than "0/0".
Date: Wed, 15 Oct 2008 20:52:47 +0200
Message-ID: <m3y70pn11c.fsf@maximus.localdomain>
References: <alpine.LNX.1.10.0810082331010.13921@bizon.gios.gov.pl>
	<E1KpkSl-00087W-GB@gondolin.me.apana.org.au>
	<20081014104621.3c2ce4d3@extreme>
	<20081015014624.GA3251@gondor.apana.org.au>
	<m34p3door9.fsf@maximus.localdomain>
	<1224086831.3984.196.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Krzysztof Oledzki <ole@ans.pl>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:38874 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750902AbYJOSwt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2008 14:52:49 -0400
In-Reply-To: <1224086831.3984.196.camel@achroite> (Ben Hutchings's message of "Wed\, 15 Oct 2008 17\:07\:10 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

> It's a Berkeley extension which spread via BSD and its inet_aton()
> function.  I don't believe it's specified in any RFC.

You may be right, I won't start searching now :-)
Anyway it was like that for years and I guess we shouldn't change it
(except perhaps for removing).

> No, a single number is treated by inet_aton() as a 32-bit address, so 10
> is equivalent to 0.0.0.10.

Hmm, I remember some routes being used without a dot, as a single
number, but OTOH you're right, it was also possible to ping
12345678. Perhaps 10 -> 10.0 was specific to something rather than
used generally, I don't know.
-- 
Krzysztof Halasa
