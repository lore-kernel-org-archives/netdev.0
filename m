From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_user.c doesn't use NLMSG_F_MULTI
Date: Thu, 14 Oct 2004 19:52:54 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1CI2I2-0001sI-00@gondolin.me.apana.org.au>
References: <20041013080705.GB3387@obroa-skai.de.gnumonks.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: laforge@gnumonks.org (Harald Welte)
In-Reply-To: <20041013080705.GB3387@obroa-skai.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Harald Welte <laforge@gnumonks.org> wrote:
> 
> If I send a GETSA with NLM_F_DUMP message from userspace, I receive a
> batch of SA messages, but they apparently don't have the F_MULTI flag
> set. 
> 
> Aren't they (all but the last msg) supposed to have the usual F_MULTI ?
> Is this by intention or a mistake?

The documentation says so but none of the existing users really care.
The doco also says that the DONE message shouldn't have F_MULTI set
but it does :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
