From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: sendfile()? Re: SO_LINGER dead: I get an immediate RST on
	2.6.24?
Date: Wed, 14 Jan 2009 22:30:26 +1100
Message-ID: <20090114113026.GC18662@gondor.apana.org.au>
References: <20090113063205.GA26047@gondor.apana.org.au> <20090113015614.3b815ad7.billfink@mindspring.com> <20090113070138.GA26480@gondor.apana.org.au> <20090114024341.76ce0dec.billfink@mindspring.com> <20090114082910.GC16692@gondor.apana.org.au> <20090114040550.407c2a0c.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ilpo.jarvinen@helsinki.fi, zbr@ioremap.net,
	bert.hubert@netherlabs.nl, h.willstrand@gmail.com,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36482 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755516AbZANLap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 06:30:45 -0500
Content-Disposition: inline
In-Reply-To: <20090114040550.407c2a0c.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 04:05:50AM -0500, Bill Fink wrote:
>
> Well, my man tcp(7) just says:
> 
>    SIOCOUTQ
>           Returns the amount of unsent data in the socket send queue.  The
>           socket must not be in LISTEN state, otherwise an error  (EINVAL)
>           is returned.

You still read man pages? :)

If you look at the actual code, SIOCOUTQ returns

	tp->write_seq - tp->snd_una

Really you can't get any more precise than that for what you want.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
