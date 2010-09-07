From: Christoph Hellwig <hch@infradead.org>
Subject: Re: RFC: Crypto API User-interface
Date: Tue, 7 Sep 2010 10:24:27 -0400
Message-ID: <20100907142427.GA14207@infradead.org>
References: <20100907084213.GA4610@gondor.apana.org.au>
 <20100907140646.GA31921@infradead.org>
 <20100907141112.GB6903@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-crypto-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100907141112.GB6903@gondor.apana.org.au>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 07, 2010 at 10:11:12PM +0800, Herbert Xu wrote:
> FWIW I don't care about user-space using kernel software crypto at
> all.  It's the security people that do.

And since when did we care about their crack pipe dreams?

> The purpose of the user-space API is to export the hardware crypto
> devices to user-space.  This means PCI devices mostly, as things
> like aesni-intel can already be used without kernel help.

I don't think they matter in practice.  We have less than a handfull
of drivers for them, and with CPUs gaining proper instructions they
are even less useful.  In addition any sane PCI card should just
allow userspace mapping of their descriptors.

> Now as a side-effect if this means that we can shut the security
> people up about adding another interface then all the better.  But
> I will certainly not go out of the way to add more crap to the
> kernel for that purpose.

So what is the real use case for this?  In addition to kernel bloat
the real fear I have is that the security wankers will just configure
the userspace crypto libraries to always use the kernel interface
just in case, and once that happens we will have to deal with the whole
mess.  Especially for RHEL and Fedora where the inmantes now run the
asylum in that respect.
