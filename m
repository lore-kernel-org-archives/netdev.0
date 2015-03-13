From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 3/6] rhashtable: Move seed init into bucket_table_alloc
Date: Fri, 13 Mar 2015 15:40:58 +0000
Message-ID: <20150313154058.GE17829@casper.infradead.org>
References: <20150313095607.GA598@gondor.apana.org.au>
 <E1YWMLA-0000Bg-H9@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57607 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945903AbbCMPk7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 11:40:59 -0400
Content-Disposition: inline
In-Reply-To: <E1YWMLA-0000Bg-H9@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/13/15 at 08:57pm, Herbert Xu wrote:
> It seems that I have already made every rehash redo the random
> seed even though my commit message indicated otherwise :)
> 
> Since we have already taken that step, this patch goes one step
> further and moves the seed initialisation into bucket_table_alloc.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Acked-by: Thomas Graf <tgraf@suug.ch>
