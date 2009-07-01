From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Wed, 1 Jul 2009 15:03:32 +0800
Message-ID: <20090701070332.GA31103@gondor.apana.org.au>
References: <87eit3l7y6.fsf@basil.nowhere.org> <20090701033924.GA29762@gondor.apana.org.au> <20090701062732.GK6760@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jolsa@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, fbl@redhat.com, nhorman@redhat.com,
	davem@redhat.com, oleg@redhat.com, eric.dumazet@gmail.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753185AbZGAHDp@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090701062732.GK6760@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 01, 2009 at 08:27:32AM +0200, Andi Kleen wrote:
>
> mfence is not needed for normal C code (not using non temporal
> stores) in the Linux memory model on x86 and is a no-op. Only the compile
> time barrier matters.

In that case this bug needs to be digged deeper regardless of
this patch.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
