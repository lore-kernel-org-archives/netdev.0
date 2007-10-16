From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/3] [NET_CLS_ACT] Use skb_act_clone
Date: Tue, 16 Oct 2007 22:06:19 +0800
Message-ID: <20071016140619.GA11763@gondor.apana.org.au>
References: <1192537921.4480.80.camel@localhost> <4714B445.1020900@trash.net> <1192540951.4480.108.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2328 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758554AbXJPOGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:06:40 -0400
Content-Disposition: inline
In-Reply-To: <1192540951.4480.108.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 16, 2007 at 09:22:31AM -0400, jamal wrote:
>
> Does the copying of tc_verd in __copy_skb_header() not cover that?

Yep, I'm pretty sure it does.

In fact this patch completely resolves my concerns about tc_verd.

Thanks!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
