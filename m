From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Mon, 6 Jun 2005 14:30:22 +0100
Message-ID: <20050606133022.GA10566@infradead.org>
References: <20050603234623.GA20088@gondor.apana.org.au> <20050604112314.GA19819@infradead.org> <20050604112606.GA1799@gondor.apana.org.au> <20050604115853.GA20335@infradead.org> <20050606115939.GA399@gondor.apana.org.au> <20050606120914.GA8317@infradead.org> <20050606124043.GA625@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050606124043.GA625@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2005 at 10:40:43PM +1000, Herbert Xu wrote:
> On Mon, Jun 06, 2005 at 01:09:14PM +0100, Christoph Hellwig wrote:
> >
> > > #if (PAGE_SHIFT > 16) || (BITS_PER_LONG > 32)
> > 
> > what is the BITS_PER_LONG check for?
> 
> These structures are normally used in arrays.  On a 64-bit machine
> the alignment requirement means that the 16-bit version will be
> padded to have the same length as the 32-bit version.  Since 32-bit
> access is usually faster we might as well get it for free.

At this point it might be easiest to just say the architecture must
declare the type in asm/types.h
