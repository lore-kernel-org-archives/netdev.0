From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Fri, 11 Jan 2008 07:36:04 +1100
Message-ID: <20080110203604.GB16621@gondor.apana.org.au>
References: <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death> <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death> <20080109201709.GF8728@gospo.usersys.redhat.com> <20080109220534.GA2692@gondor.apana.org.au> <7603.1199920750@death> <20080110005809.GA3851@gondor.apana.org.au> <20080110145144.GH8728@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, Krzysztof Oledzki <olel@ans.pl>,
	netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1251 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750964AbYAJUgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 15:36:45 -0500
Content-Disposition: inline
In-Reply-To: <20080110145144.GH8728@gospo.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 09:51:44AM -0500, Andy Gospodarek wrote:
>
> That wasn't the only purpose, Herbert.  Making sure that calls to
> dev_set_mac_address were called from process context was important at
> the time of the coding as well since at least the tg3 driver took locks
> that could not be taken reliably in soft-irq context.  Michael Chan
> fixed this here:

Sure, but where do you call that function while holding the bond lock?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
