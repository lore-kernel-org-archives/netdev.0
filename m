From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: fix the xfrm_policy/state_walk
Date: Wed, 22 Apr 2015 15:57:55 +0800
Message-ID: <20150422075755.GA9163@gondor.apana.org.au>
References: <1429689214-10827-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:33945 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965553AbbDVH57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2015 03:57:59 -0400
Content-Disposition: inline
In-Reply-To: <1429689214-10827-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2015 at 03:53:34PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> If the walk from input is not empty, the following loop should start from
> the walk->next, since walk is list header, and the last policy in previours
> loop is connected walk tailor by list_move_tail()
> 
> Fixes: 12a169e7d8f(ipsec: Put dumpers on the dump list)
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

This is not a bug fix but an optimisation.  The walker entries are
all marked as dead and will be skipped by the loop.

However, I don't see anything wrong with this optimisation.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
