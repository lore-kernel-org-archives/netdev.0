From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][net-next][v2] xfrm: optimise the use of walk list header
 in xfrm_policy/state_walk
Date: Wed, 22 Apr 2015 17:13:18 +0800
Message-ID: <20150422091318.GA9719@gondor.apana.org.au>
References: <1429693794-17256-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:56117 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965778AbbDVJNV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 05:13:21 -0400
Content-Disposition: inline
In-Reply-To: <1429693794-17256-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2015 at 05:09:54PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> The walk from input is the list header, and marked as dead, and will
> be skipped in loop.
> 
> list_first_entry() can be used to return the true usable value from
> walk if walk is not empty
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
