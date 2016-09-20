From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 3/7] rhashtable: Call library function
 alloc_bucket_locks
Date: Tue, 20 Sep 2016 17:29:47 +0800
Message-ID: <20160920092947.GA20944@gondor.apana.org.au>
References: <1473895376-347096-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
        roopa@cumulusnetworks.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:43986 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753997AbcITJaA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:30:00 -0400
Content-Disposition: inline
In-Reply-To: <1473895376-347096-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> To allocate the array of bucket locks for the hash table we now
> call library function alloc_bucket_spinlocks. This function is
> based on the old alloc_bucket_locks in rhashtable and should
> produce the same effect.
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Tom Herbert <tom@herbertland.com>

On second thought when I do the nested allocation I could simply
restore this function.  So

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
