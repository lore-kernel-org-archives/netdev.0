From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 22:39:00 +0800
Message-ID: <20100907143859.GA7448@gondor.apana.org.au>
References: <20100907084213.GA4610@gondor.apana.org.au> <20100907140646.GA31921@infradead.org> <20100907141112.GB6903@gondor.apana.org.au> <20100907142427.GA14207@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:46120 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910Ab0IGOjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 10:39:01 -0400
Content-Disposition: inline
In-Reply-To: <20100907142427.GA14207@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 07, 2010 at 10:24:27AM -0400, Christoph Hellwig wrote:
> 
> I don't think they matter in practice.  We have less than a handfull
> of drivers for them, and with CPUs gaining proper instructions they
> are even less useful.  In addition any sane PCI card should just
> allow userspace mapping of their descriptors.

I totally agree that mainstream CPUs won't need this at all.

However we still have embedded users where the CPUs may not be
powerful enough per se or where they want to use their CPUs for
other work.

There are also cases such as the Niagra SPU which may not be
easy to manage from user-space (correct me if I'm wrong Dave).

> > Now as a side-effect if this means that we can shut the security
> > people up about adding another interface then all the better.  But
> > I will certainly not go out of the way to add more crap to the
> > kernel for that purpose.
> 
> So what is the real use case for this?  In addition to kernel bloat
> the real fear I have is that the security wankers will just configure
> the userspace crypto libraries to always use the kernel interface
> just in case, and once that happens we will have to deal with the whole
> mess.  Especially for RHEL and Fedora where the inmantes now run the
> asylum in that respect.

I will let the security people answer this :)

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
