From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] ipv4: check rt_genid in dst_check
Date: Fri, 19 Mar 2010 13:18:56 +0800
Message-ID: <20100319051856.GA22079@gondor.apana.org.au>
References: <1268912902-27050-1-git-send-email-timo.teras@iki.fi> <20100318121146.GA13307@gondor.apana.org.au> <20100318.221649.02256374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47094 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751339Ab0CSFTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 01:19:04 -0400
Content-Disposition: inline
In-Reply-To: <20100318.221649.02256374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 18, 2010 at 10:16:49PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 18 Mar 2010 20:11:46 +0800
> 
> > On Thu, Mar 18, 2010 at 01:48:22PM +0200, Timo Teras wrote:
> >> @@ -1726,7 +1726,9 @@ static void ip_rt_update_pmtu(struct dst_entry *dst, u32 mtu)
> >>  
> >>  static struct dst_entry *ipv4_dst_check(struct dst_entry *dst, u32 cookie)
> >>  {
> >> -	return NULL;
> >> +	if (dst && dst->dev && rt_is_expired((struct rtable *) dst))
                                                              ^

While you're at it, please delete this space to preemptively
stop anyone from sending a checkpatch patch :)

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
