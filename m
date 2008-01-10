From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Thu, 10 Jan 2008 16:03:53 -0500
Message-ID: <20080110210353.GI8728@gospo.usersys.redhat.com>
References: <17850.1199865514@death> <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death> <20080109201709.GF8728@gospo.usersys.redhat.com> <20080109220534.GA2692@gondor.apana.org.au> <7603.1199920750@death> <20080110005809.GA3851@gondor.apana.org.au> <20080110145144.GH8728@gospo.usersys.redhat.com> <20080110203604.GB16621@gondor.apana.org.au> <25832.1199998246@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Andy Gospodarek <andy@greyhouse.net>,
	Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43932 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752373AbYAJVFk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jan 2008 16:05:40 -0500
Content-Disposition: inline
In-Reply-To: <25832.1199998246@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 12:50:46PM -0800, Jay Vosburgh wrote:
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> >On Thu, Jan 10, 2008 at 09:51:44AM -0500, Andy Gospodarek wrote:
> >>
> >> That wasn't the only purpose, Herbert.  Making sure that calls to
> >> dev_set_mac_address were called from process context was important at
> >> the time of the coding as well since at least the tg3 driver took locks
> >> that could not be taken reliably in soft-irq context.  Michael Chan
> >> fixed this here:
> >
> >Sure, but where do you call that function while holding the bond lock?
> 
> 	If I recall correctly, the problem was that tg3, et al, did
> things that might sleep, and bonding was calling from a timer context,
> which couldn't sleep.  It wasn't about the lock.
> 

Exactly, I was just about to post the same.
