From: David Miller <davem@davemloft.net>
Subject: Re: netlink: Fix netlink_insert EADDRINUSE error
Date: Fri, 16 Jan 2015 02:38:30 -0500 (EST)
Message-ID: <20150116.023830.1727046242939800788.davem@davemloft.net>
References: <20150116062348.GA8588@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ying.xue@windriver.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbbAPHie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 02:38:34 -0500
In-Reply-To: <20150116062348.GA8588@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 16 Jan 2015 17:23:48 +1100

> The patch c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink:
> eliminate nl_sk_hash_lock") introduced a bug where the EADDRINUSE
> error has been replaced by ENOMEM.  This patch rectifies that
> problem.
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
