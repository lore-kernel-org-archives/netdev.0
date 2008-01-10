From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Fri, 11 Jan 2008 08:05:07 +1100
Message-ID: <20080110210507.GA17344@gondor.apana.org.au>
References: <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death> <20080109201709.GF8728@gospo.usersys.redhat.com> <20080109220534.GA2692@gondor.apana.org.au> <7603.1199920750@death> <20080110005809.GA3851@gondor.apana.org.au> <20080110145144.GH8728@gospo.usersys.redhat.com> <20080110203604.GB16621@gondor.apana.org.au> <25832.1199998246@death> <20080110210353.GI8728@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, Krzysztof Oledzki <olel@ans.pl>,
	netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1630 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751918AbYAJVFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 16:05:31 -0500
Content-Disposition: inline
In-Reply-To: <20080110210353.GI8728@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 04:03:53PM -0500, Andy Gospodarek wrote:
>
> > >Sure, but where do you call that function while holding the bond lock?
> > 
> > 	If I recall correctly, the problem was that tg3, et al, did
> > things that might sleep, and bonding was calling from a timer context,
> > which couldn't sleep.  It wasn't about the lock.
> 
> Exactly, I was just about to post the same.

In other words, changing read_lock on bond->lock to read_lock_bh doesn't
affect this one bit.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
