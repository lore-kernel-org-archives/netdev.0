From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 3151] New: IPSEC triggers "bad: scheduling while atomic!" errors.
Date: Wed, 04 Aug 2004 19:55:51 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <E1BsIUx-0001As-00@gondolin.me.apana.org.au>
References: <20040803224319.50363100.akpm@osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20040803224319.50363100.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
> Looks like a lock/unlock imbalance somewhere in the 2.6.7 ipsec code.

Yes this is most likely the missing unlock in xfrm_policy_timer() that
was fixed not so long ago.

However, that bug was only introduced in 2.6.7 and the submitter says
that he saw this with 2.6.6.  So this might be something else.

So the submitter should test 2.6.8-rc3 to see if it's still there or not.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
