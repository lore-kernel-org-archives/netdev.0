From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Wed, 1 Jul 2009 16:31:44 +0800
Message-ID: <20090701083144.GA31863@gondor.apana.org.au>
References: <87eit3l7y6.fsf@basil.nowhere.org> <20090701033924.GA29762@gondor.apana.org.au> <20090701062732.GK6760@one.firstfloor.org> <20090701070332.GA31103@gondor.apana.org.au> <20090701072226.GN6760@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jolsa@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, oleg@redhat.com, eric.dumazet@gmail.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56257 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750782AbZGAIbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 04:31:45 -0400
Content-Disposition: inline
In-Reply-To: <20090701072226.GN6760@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 01, 2009 at 09:22:26AM +0200, Andi Kleen wrote:
>
> Agreed.
> 
> I suspect the reordering of the wake queue tests might makes a difference, but
> in this case to ensure they are always tested in the proper order by
> the compiler would need more smp_rmb()s

I just looked up the original bug report and it's against RHEL4
which is a 2.6.9 kernel.  Jiri, have we reproduced this on a more
recent kernel?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
