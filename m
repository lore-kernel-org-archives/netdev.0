From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch]net/xfrm/xfrm_state.c: replace timer with delayed_work
Date: Sun, 27 Apr 2008 09:19:06 +0800
Message-ID: <20080427011906.GB662@gondor.apana.org.au>
References: <20080217.000049.88383747.xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
To: WANG Cong <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33899 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752564AbYD0BTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2008 21:19:12 -0400
Content-Disposition: inline
In-Reply-To: <20080217.000049.88383747.xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 17, 2008 at 12:00:49AM +0800, WANG Cong wrote:
> 
> Also suggested by Herbert Xu, using workqueue is better than timer
> for net/xfrm/xfrm_state.c, so replace them with delayed_work.
> 
> Note that, this patch is not fully tested, just compile and
> run as a whole on an Intel Core Duo matchine. So should be
> in -mm first.
> 
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: David Miller <davem@davemloft.net>

As with the xfrm policy patch, the spin lock here needs to disable
BH.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
