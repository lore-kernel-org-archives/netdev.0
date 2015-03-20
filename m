From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][net-next] rhashtable: ensure that ht->p.min_size is
 round up to the power of two
Date: Fri, 20 Mar 2015 19:49:47 +1100
Message-ID: <20150320084947.GA16659@gondor.apana.org.au>
References: <1426839237-10345-1-git-send-email-rongqing.li@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, tgraf@suug.ch
To: rongqing.li@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:33988 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750977AbbCTIt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 04:49:59 -0400
Content-Disposition: inline
In-Reply-To: <1426839237-10345-1-git-send-email-rongqing.li@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 04:13:57PM +0800, rongqing.li@windriver.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> ht->p.min_size will be reset to params->min_size, which has been set
> to the params->min_size round up of the power of two, should be kept
> 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> Cc: Thomas Graf <tgraf@suug.ch>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>

Thanks for the patch but I've already fixed this in my tree which
I will post soon and I'd like to avoid having to rebase it yet
again for something as trivial as this.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
