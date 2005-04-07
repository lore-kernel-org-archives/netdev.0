From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fwd: atomic_dec_and_test for child dst needed in dst_destroy?
Date: Thu, 07 Apr 2005 21:23:41 +1000
Message-ID: <E1DJV6r-0002Nu-00@gondolin.me.apana.org.au>
References: <4253A3A0.800@calsoftinc.com>
Cc: christoph@lameter.com, netdev@oss.sgi.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: pravins@calsoftinc.com (pravin b shelar)
In-Reply-To: <4253A3A0.800@calsoftinc.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

pravin b shelar <pravins@calsoftinc.com> wrote:
>
> This patch  will remove the need for atomic_dec_and_test for this 
> particular case.
> Now we can break down the atomic_dec_and_test to atomic_dec & atomic_read.

Sorry I overlooked your patch.  Otherwise we could have solved this
one day earlier :)

> Please comment.

There is just one problem.  We need an extra barrier before or after
the goto since we no longer have the implicit barrier given by
atomic_dec_and_test.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
