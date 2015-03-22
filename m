From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: provide len to obj_hashfn
Date: Sun, 22 Mar 2015 18:22:02 +1100
Message-ID: <20150322072202.GA2125@gondor.apana.org.au>
References: <1426952290-18962-1-git-send-email-kaber@trash.net>
 <1426952290-18962-2-git-send-email-kaber@trash.net>
 <20150321230618.GB31869@gondor.apana.org.au>
 <20150322044746.GA31192@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, davem@davemloft.net, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150322044746.GA31192@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Mar 22, 2015 at 04:47:47AM +0000, Patrick McHardy wrote:
>
> Correct, the set extensions are added on demand and contain an offset
> for every extension type. The offset is usually not, but may be
> different for different elements.
> 
> Embedding the offset is not something I want to do. Again, this stuff
> is meant to be as compact as possible and it serves no purpose at all.
> What is the problem with using these callbacks?

Maybe I'm not seeing everything but from this patch and what
you sent me last time ([PATCH 0/9 WIP] nf_tables: set extensions
and dynamic updates) it appears that NFT_SET_EXT_KEY is always
present so if you always added it first to the template it would
be at a fixed offset, no?

But whatever, I don't really care about this so go ahead and add
the key length to obj_hash.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
