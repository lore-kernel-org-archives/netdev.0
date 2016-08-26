From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next,v2 1/2] rhashtable: add
 rhashtable_lookup_get_insert_key()
Date: Fri, 26 Aug 2016 14:15:20 +0200
Message-ID: <20160826121520.GA8729@salvia>
References: <1472136087-1338-1-git-send-email-pablo@netfilter.org>
 <20160826112736.GB20096@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, tgraf@suug.ch,
        netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160826112736.GB20096@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 26, 2016 at 07:27:36PM +0800, Herbert Xu wrote:
> On Thu, Aug 25, 2016 at 04:41:26PM +0200, Pablo Neira Ayuso wrote:
> > This patch modifies __rhashtable_insert_fast() so it returns the
> > existing object that clashes with the one that you want to insert.
> > In case the object is successfully inserted, NULL is returned.
> > Otherwise, you get an error via ERR_PTR().
> > 
> > This patch adapts the existing callers of __rhashtable_insert_fast()
> > so they handle this new logic, and it adds a new
> > rhashtable_lookup_get_insert_key() interface to fetch this existing
> > object.
> > 
> > nf_tables needs this change to improve handling of EEXIST cases via
> > honoring the NLM_F_EXCL flag and by checking if the data part of the
> > mapping matches what we have.
> > 
> > Cc: Herbert Xu <herbert@gondor.apana.org.au>
> > Cc: Thomas Graf <tgraf@suug.ch>
> > Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks Herbert!

@David, would you be OK if I get this rhashtable update through
nf-next given that I have a follow up patch that depending on this?
Will be sending a pull request asap so we don't get out of sync.
