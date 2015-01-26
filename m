From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 09:42:16 +1100
Message-ID: <20150126224216.GA30551@gondor.apana.org.au>
References: <E1YFWUl-0004gE-SH@gondolin.me.apana.org.au>
 <063D6719AE5E284EB5DD2968C1650D6D1CAD2C12@AcuExch.aculab.com>
 <20150126222259.GC30116@gondor.apana.org.au>
 <20150126.143613.1798698028405169123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David.Laight@ACULAB.COM, tgraf@suug.ch, ying.xue@windriver.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150126.143613.1798698028405169123.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 26, 2015 at 02:36:13PM -0800, David Miller wrote:
>
> I really think the amount of time and effort being put into making
> the walker function properly is excessive.
> 
> Let's just say that if you want to use rhashtable, you have to use a
> linked list, or similar separate mechanism, to have stable walks of
> the entire set of objects.

I definitely agree with that :)

However, I'd really like to get these primitives in first so that
at least I can convert the existing rhashtable walkers over and
get on with implementing rhashtable rehashing which is what I set
out to do.

As otherwise we'd be looking at fixing the existing users (in
particular, nft_hash) properly which might take a lot more time.

If and when we finally fix the existing users we can always remove
these primitives.

FWIW when I first wrote this patch I called it
rhashtable_walk_dangerously, I can readopt that name if you think
that will dissuade people from using it.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
