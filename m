From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH nf-next,v2 1/2] rhashtable: add
 rhashtable_lookup_get_insert_key()
Date: Fri, 26 Aug 2016 19:27:36 +0800
Message-ID: <20160826112736.GB20096@gondor.apana.org.au>
References: <1472136087-1338-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, tgraf@suug.ch,
        netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:40572 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751503AbcHZL1z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 07:27:55 -0400
Content-Disposition: inline
In-Reply-To: <1472136087-1338-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 04:41:26PM +0200, Pablo Neira Ayuso wrote:
> This patch modifies __rhashtable_insert_fast() so it returns the
> existing object that clashes with the one that you want to insert.
> In case the object is successfully inserted, NULL is returned.
> Otherwise, you get an error via ERR_PTR().
> 
> This patch adapts the existing callers of __rhashtable_insert_fast()
> so they handle this new logic, and it adds a new
> rhashtable_lookup_get_insert_key() interface to fetch this existing
> object.
> 
> nf_tables needs this change to improve handling of EEXIST cases via
> honoring the NLM_F_EXCL flag and by checking if the data part of the
> mapping matches what we have.
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
