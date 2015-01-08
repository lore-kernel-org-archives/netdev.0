From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net: Prevent multiple NAPI instances co-existing in the
 list
Date: Thu, 8 Jan 2015 22:15:54 +1100
Message-ID: <20150108111554.GA8720@gondor.apana.org.au>
References: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, kernel.org.gnu@gmail.com
To: Dennis Chen <kernel.org.gnu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:58276 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288AbbAHLP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 06:15:57 -0500
Content-Disposition: inline
In-Reply-To: <CA+U0gVh+TyEUJ+qmg+FE=UhvvQywfNxcouCyv1sutZ3fav5FAw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dennis Chen <kernel.org.gnu@gmail.com> wrote:
> Some drivers may clear the NAPI_STATE_SCHED bit upon the state of the
> NAPI instance after exhaust the budget in the poll function, which
> will open a window for next device interrupt handler to insert a same
> instance to the list after calling list_add_tail(&n->poll_list,
> repoll) if we don't set this bit.
> 
> Signed-off-by: Dennis Chen <kernel.org.gnu@gmail.com>

Which driver is doing this?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
