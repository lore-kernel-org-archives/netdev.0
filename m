From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2 net-next 3/3] rhashtable: Add scored lookups
Date: Wed, 15 Jul 2015 08:18:54 +0800
Message-ID: <20150715001854.GA29934@gondor.apana.org.au>
References: <1436917549-3666965-1-git-send-email-tom@herbertland.com>
 <1436917549-3666965-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
	kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:37718 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091AbbGOATG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 20:19:06 -0400
Content-Disposition: inline
In-Reply-To: <1436917549-3666965-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 14, 2015 at 04:45:49PM -0700, Tom Herbert wrote:
>
> +		} else if (score == best_score) {
> +			matches++;
> +			if (reciprocal_scale(khash, matches) == 0)
> +				result = he;
> +			khash = next_pseudo_random32(khash);
> +		}

Note that during a rehash you can encounter the same object multiple
times, does this logic still work in that case?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
