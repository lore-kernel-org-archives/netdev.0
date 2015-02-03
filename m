From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Move hash_rnd into bucket_table
Date: Mon, 02 Feb 2015 19:19:56 -0800 (PST)
Message-ID: <20150202.191956.404010205495035337.davem@davemloft.net>
References: <20150131102150.GA29498@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366AbbBCDT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 22:19:57 -0500
In-Reply-To: <20150131102150.GA29498@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 31 Jan 2015 21:21:50 +1100

> Currently hash_rnd is a parameter that users can set.  However,
> no existing users set this parameter.  It is also something that
> people are unlikely to want to set directly since it's just a
> random number.
>     
> In preparation for allowing the reseeding/rehashing of rhashtable,
> this patch moves hash_rnd into bucket_table so that it's now an
> internal state rather than a parameter.
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied to net-next, thanks a lot.
