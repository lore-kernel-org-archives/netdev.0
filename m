From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] Uninline the sk_stream_alloc_pskb
Date: Thu, 29 Nov 2007 18:45:15 +1100
Message-ID: <20071129074515.GA30066@gondor.apana.org.au>
References: <474AFEE4.4040702@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4483 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760597AbXK2Hpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 02:45:30 -0500
Content-Disposition: inline
In-Reply-To: <474AFEE4.4040702@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 08:14:12PM +0300, Pavel Emelyanov wrote:
> This function seems too big for inlining. Indeed, it saves
> half-a-kilo when uninlined:
> 
> add/remove: 1/0 grow/shrink: 0/7 up/down: 195/-719 (-524)
> function                                     old     new   delta
> sk_stream_alloc_pskb                           -     195    +195
> ip_rt_init                                   529     525      -4
> __inet_lookup_listener                       284     274     -10
> tcp_sendmsg                                 2583    2486     -97
> tcp_sendpage                                1449    1305    -144
> tso_fragment                                 417     267    -150
> tcp_fragment                                1149     992    -157
> __tcp_push_pending_frames                   1998    1841    -157
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6.25.  Thanks Pavel!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
