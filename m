From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/3] rhashtable: Handle table allocation failure during
 insertion
Date: Sat, 11 Feb 2017 19:22:12 +0800
Message-ID: <20170211112212.GA1516@gondor.apana.org.au>
References: <20170207123827.GA14678@gondor.apana.org.au>
 <20170208.132642.68242478649592606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:36097 "EHLO
        helcar.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751235AbdBKS6i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 13:58:38 -0500
Content-Disposition: inline
In-Reply-To: <20170208.132642.68242478649592606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 01:26:42PM -0500, David Miller wrote:
> rhashtable is indeed getting quite complex, but I understand your
> motivation for doing this work.
> 
> I also agree that only true OOM situations should cause insertion
> failures.
> 
> Given the delicate nature of change rhashtable this way, I'm going
> to let these changes sit for a couple days before applying them.

No problems.  Good thing too as the lkp found a bug in my RCU
annotation.  So I will send a v2 with that fixed.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
