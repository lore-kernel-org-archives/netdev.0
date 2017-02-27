From: David Miller <davem@davemloft.net>
Subject: Re: [bug report] rhashtable: Add nested tables
Date: Sun, 26 Feb 2017 21:34:43 -0500 (EST)
Message-ID: <20170226.213443.335375063360642764.davem@davemloft.net>
References: <20170216121703.GA26276@mwanda>
        <20170225143811.GA28272@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, kernel-janitors@vger.kernel.org,
        netdev@vger.kernel.org, tgraf@suug.ch
To: herbert@gondor.apana.org.au
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170225143811.GA28272@gondor.apana.org.au>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 25 Feb 2017 22:38:11 +0800

> Subject: rhashtable: Fix use before NULL check in bucket_table_free
> 
> Dan Carpenter reported a use before NULL check bug in the function
> bucket_table_free.  In fact we don't need the NULL check at all as
> no caller can provide a NULL argument.  So this patch fixes this by
> simply removing it.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks Herbert.
