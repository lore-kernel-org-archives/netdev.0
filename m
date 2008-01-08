From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch] xfrm_policy_destroy: rename and relative fixes
Date: Tue, 8 Jan 2008 17:15:16 +1100
Message-ID: <20080108061516.GD2529@gondor.apana.org.au>
References: <20080103120550.GB2498@hacking>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: WANG Cong <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4437 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754551AbYAHGPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:15:22 -0500
Content-Disposition: inline
In-Reply-To: <20080103120550.GB2498@hacking>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 03, 2008 at 08:05:50PM +0800, WANG Cong wrote:
> 
> Since __xfrm_policy_destroy is used to destory the resources
> allocated by xfrm_policy_alloc. So using the name
> __xfrm_policy_destroy is not correspond with xfrm_policy_alloc.
> Rename it to xfrm_policy_destroy.
> 
> And along with some instances that call xfrm_policy_alloc
> but not using xfrm_policy_destroy to destroy the resource,
> fix them.
> 
> Cc: David Miller <davem@davemloft.net>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: WANG Cong <xiyou.wangcong@gmail.com>

This patch looks OK to me.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
