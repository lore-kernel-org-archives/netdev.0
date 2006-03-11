From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2.6 patch] net/decnet/dn_route.c: fix inconsequent NULL checking
Date: Sat, 11 Mar 2006 13:51:28 +1100
Message-ID: <E1FHuCW-0005k2-00@gondolin.me.apana.org.au>
References: <20060310230233.GB21864@stusta.de>
Cc: patrick@tykepenguin.com, linux-decnet-user@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752327AbWCKCvj@vger.kernel.org>
To: bunk@stusta.de (Adrian Bunk)
In-Reply-To: <20060310230233.GB21864@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk <bunk@stusta.de> wrote:
> The Coverity checker noted this inconsequent NULL checking in
> dnrt_drop().
> 
> Since all callers ensure that NULL isn't passed, we can simply remove 
> the check.

Ack.

In fact it's pointless even if the caller didn't check as dst_release
checks it anyway.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
