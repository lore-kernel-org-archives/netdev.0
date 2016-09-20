From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next 5/7] rhashtable: abstract out function to get
 hash
Date: Tue, 20 Sep 2016 17:36:59 +0800
Message-ID: <20160920093659.GA20975@gondor.apana.org.au>
References: <1473895376-347096-6-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
        roopa@cumulusnetworks.com, kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:54086 "EHLO
        helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752560AbcITJhJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 05:37:09 -0400
Content-Disposition: inline
In-Reply-To: <1473895376-347096-6-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> wrote:
> Split out most of rht_key_hashfn which is calculating the hash into
> its own function. This way the hash function can be called separately to
> get the hash value.
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>
> Signed-off-by: Tom Herbert <tom@herbertland.com>

I don't get this one.  You're just using jhash, right? Why not
call jhash directly instead of rht_get_key_hashfn?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
