From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: Error: an inet prefix is expected rather than "0/0".
Date: Wed, 15 Oct 2008 17:35:06 +0200
Message-ID: <m34p3door9.fsf@maximus.localdomain>
References: <alpine.LNX.1.10.0810082331010.13921@bizon.gios.gov.pl>
	<E1KpkSl-00087W-GB@gondolin.me.apana.org.au>
	<20081014104621.3c2ce4d3@extreme>
	<20081015014624.GA3251@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Krzysztof Oledzki <ole@ans.pl>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:42328 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672AbYJOPfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Oct 2008 11:35:10 -0400
In-Reply-To: <20081015014624.GA3251@gondor.apana.org.au> (Herbert Xu's message of "Wed\, 15 Oct 2008 09\:46\:24 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> writes:

> How about just keeping Alexey's code? POSIX doesn't restrict
> the IP address format command utilities should accept.  So to
> me 127.2.0.0 is a perfectly acceptable interpretation of the
> partial address 127.2.

Then it would be better to disallow such things. The normal meaning
for "127.2" was always 127.0.0.2, and it was widely documented and
used (though perhaps in RFCs, not in POSIX). Some people use "10.1"
syntax all the time.

> This also has the benefit of not breaking any existing scripts
> that already work.  The scripts which are broken will remain
> broken which doesn't surprise anyone.

Any script which uses 127.2 to mean 127.2.0.0 is IMHO broken, though
I have never seen anything like that.

Rules always have been simple:
10	- 10.0.0.0
10.1	- 10.0.0.1
10.1.2	- 10.0.1.2

If it can't stay this way, lets remove this shortened notation
completely.
-- 
Krzysztof Halasa
