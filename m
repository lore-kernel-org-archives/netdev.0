From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] Eliminate unused argument from sk_stream_alloc_pskb
Date: Thu, 29 Nov 2007 21:23:25 +1100
Message-ID: <20071129102325.GB22537@gondor.apana.org.au>
References: <474AFFA7.2090102@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1770 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754604AbXK2KXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 05:23:35 -0500
Content-Disposition: inline
In-Reply-To: <474AFFA7.2090102@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 08:17:27PM +0300, Pavel Emelyanov wrote:
> The 3rd argument is always zero (according to grep :) Eliminate
> it and merge the function with sk_stream_alloc_skb.
> 
> This saves 44 more bytes, and together with the previous patch
> we have:
> 
> add/remove: 1/0 grow/shrink: 0/8 up/down: 183/-751 (-568)
> function                                     old     new   delta
> sk_stream_alloc_skb                            -     183    +183
> ip_rt_init                                   529     525      -4
> arp_ignore                                   112     107      -5
> __inet_lookup_listener                       284     274     -10
> tcp_sendmsg                                 2583    2481    -102
> tcp_sendpage                                1449    1300    -149
> tso_fragment                                 417     258    -159
> tcp_fragment                                1149     988    -161
> __tcp_push_pending_frames                   1998    1837    -161

Also applied to net-2.6.25.  Thanks.

> Question: is this 2.6.24 material (good space saving) or should I
> rework this against 2.6.25 (it applies with fuzzes, but seems to
> compile)?

I guess I've answered this question :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
