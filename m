From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: virt-manager broken by bind(0) in net-next.
Date: Fri, 30 Jan 2009 23:53:37 +1100
Message-ID: <20090130125337.GA7155@gondor.apana.org.au>
References: <20090130112125.GA9908@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: berrange@redhat.com, shemminger@vyatta.com,
	et-mgmt-tools@redhat.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50836 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752572AbZA3M7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 07:59:07 -0500
Content-Disposition: inline
In-Reply-To: <20090130112125.GA9908@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov <zbr@ioremap.net> wrote:
>
> So it is not explicit bind call, but port autoselection in the
> connect(). Can you check what errno is returned?
> Did I understand it right, that connect fails, you try different
> address, but then suddenly all those sockets become 'alive'?

Yes, I think a good strace vs. a bad strace would be really helpful
in these cases.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
