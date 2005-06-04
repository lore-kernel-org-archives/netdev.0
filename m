From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Sat, 4 Jun 2005 12:23:14 +0100
Message-ID: <20050604112314.GA19819@infradead.org>
References: <20050603234623.GA20088@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20050603234623.GA20088@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 04, 2005 at 09:46:23AM +1000, Herbert Xu wrote:
> struct crypto_frag {
> 	struct page *page;
> 	u16 offset;
> 	u16 length;
> };

we have this structure as skb_frag_struct and bio_vec already, care
to use the same structure with a generic name for all of them?
