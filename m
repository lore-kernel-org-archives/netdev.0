From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] Replace scatterlist with crypto_frag
Date: Mon, 06 Jun 2005 15:36:02 -0700 (PDT)
Message-ID: <20050606.153602.23015220.davem@davemloft.net>
References: <20050604102204.GA1214@gondor.apana.org.au>
	<20050604142939.4e2efc55@zanzibar.2ka.mipt.ru>
	<20050604103249.GA1378@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, jmorris@redhat.com, linux-crypto@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: herbert@gondor.apana.org.au
In-Reply-To: <20050604103249.GA1378@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 4 Jun 2005 20:32:49 +1000

> On Sat, Jun 04, 2005 at 02:29:39PM +0400, Evgeniy Polyakov wrote:
> > 
> > But without sg we sill save 4*sizeof(dma addr) - is it really a price?
> 
> We're also reducing the offset/length to 16 bits from 32 bits so we're
> shaving off half the size.

Note, it is still going to be a 16 byte structure on 64-bit
machines.  This is mainly due to the 8-byte alignment needed
by the page pointer.

I'm not objecting to your ideas, just mentioning this fact...

I am also puzzled as to where the "4" came from :-)
