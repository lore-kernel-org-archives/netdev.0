From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH net-next 2/4] udp: Handle large UFO packets from untrusted sources
Date: Wed, 10 Jun 2009 13:10:40 +0930
Message-ID: <200906101310.41094.rusty@rustcorp.com.au>
References: <1244247391.1526.171.camel@w-sridhar.beaverton.ibm.com> <20090608051608.GA19748@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56604 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753911AbZFJDkk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 23:40:40 -0400
In-Reply-To: <20090608051608.GA19748@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Jun 2009 02:46:08 pm Herbert Xu wrote:
> On Fri, Jun 05, 2009 at 05:16:31PM -0700, Sridhar Samudrala wrote:
> > +	/* Software UFO is not yet supported */
> > +	segs = ERR_PTR(-EPROTONOSUPPORT);
>
> Hmm, we need to fill this in before you start using it for virt.
> After all, it's very difficult for the guest to know whether the
> output device on the host is going to be able to do UFO or not.

Yep, no point telling the guest we support UFO if we don't!

Cheers,
Rusty.
