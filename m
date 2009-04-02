From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 2 Apr 2009 11:09:35 +0800
Message-ID: <20090402030935.GA27836@gondor.apana.org.au>
References: <49D3B64F.6070703@codemonkey.ws>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, ghaskins@novell.com,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38038 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751291AbZDBDJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 23:09:59 -0400
Content-Disposition: inline
In-Reply-To: <49D3B64F.6070703@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anthony Liguori <anthony@codemonkey.ws> wrote:
>
> That said, I don't think we're bound today by the fact that we're in 
> userspace.  Rather we're bound by the interfaces we have between the 
> host kernel and userspace to generate IO.  I'd rather fix those 
> interfaces than put more stuff in the kernel.

I'm sorry but I totally disagree with that.  By having our IO
infrastructure in user-space we've basically given up the main
advantage of kvm, which is that the physical drivers operate in
the same environment as the hypervisor.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
