From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net PATCH] ip_vti/ip6_vti: Clear skb->mark when resetting
 skb->dev in receive path
Date: Sat, 16 May 2015 20:34:58 +0800
Message-ID: <20150516123457.GB683@gondor.apana.org.au>
References: <20150514032833.GF3853@gondor.apana.org.au>
 <55543D4F.8050306@gmail.com>
 <20150514062614.GA6320@gondor.apana.org.au>
 <20150515.123726.1298734930500737780.davem@redhat.com>
 <555645A3.6010509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@redhat.com>, alexander.h.duyck@redhat.com,
	netdev@vger.kernel.org, steffen.klassert@secunet.com, tgraf@suug.ch
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:38537 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755287AbbEPMfC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 08:35:02 -0400
Content-Disposition: inline
In-Reply-To: <555645A3.6010509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 15, 2015 at 12:14:43PM -0700, Alexander Duyck wrote:
>
> >Yeah, this mark handling via tunnel->parms.o_key looks not so good.
> 
> So is there any recommendations for an alternative to make it so
> that the ipsec endpoint is identified as needing to be encrypted or
> decrypted?  If needed I could probably take a day or two to try and
> address it as I still have a few other minor things I want to try
> and fix such as the MTU configuration for vti/vti6.

I'd like to hear from Steffen as to whether there is anything
in userspace that relies on the mark being used in this way by
vti.  If not it should be easy to get rid of it and use some
field that's not exposed to user-space.  If there is then this
would be tricky to resolve.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
