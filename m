From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 4138] New: ipsec with racoon in transport mode with esp and ah hangs (problem is in xfrm_state_add)
Date: Wed, 9 Mar 2005 10:00:08 +1100
Message-ID: <20050308230008.GA27450@gondor.apana.org.au>
References: <E1CvZCT-00017g-00@gondolin.me.apana.org.au> <200501311640.16118.au@unterluggauer.org> <20050131211102.GA20323@gondor.apana.org.au> <422E28D6.1070103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Unterluggauer <au@unterluggauer.org>, netdev@oss.sgi.com
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <422E28D6.1070103@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 08, 2005 at 11:36:06PM +0100, Patrick McHardy wrote:
> 
> You're right, but I think there is also kernel misbehaviour here that
> is fixed by the patch for __xfrm_state_find_acq_byseq() I sent to Dave
> earlier. Andreas, can you try this patch please ?

Good catch.  That should also make racoon work.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
