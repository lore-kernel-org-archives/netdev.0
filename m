From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: Fix inter family IPsec tunnel handling again
Date: Thu, 3 Jul 2008 11:18:36 +0200
Message-ID: <20080703091836.GK9549@secunet.com>
References: <20080703085542.GJ9549@secunet.com> <20080703090522.GB27923@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:48534 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758587AbYGCMSS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Jul 2008 08:18:18 -0400
Content-Disposition: inline
In-Reply-To: <20080703090522.GB27923@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 03, 2008 at 05:05:22PM +0800, Herbert Xu wrote:
> On Thu, Jul 03, 2008 at 10:55:42AM +0200, Steffen Klassert wrote:
> >
> > +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> > +        case IPPROTO_IPV6:
> > +                if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
> > +                        goto out;
> > +                break;
> > +#endif
> 
> This is supposed to use protocol-agnostic data so why do you need
> the ifdef?
> 
Well, I added the ifdef because it was there in the 2.6.24 code,
I could remove it and resend if you agree with the rest of the patch.

Steffen
