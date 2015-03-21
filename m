From: David Miller <davem@davemloft.net>
Subject: Re: [v1 PATCH 0/7] rhashtable: Introduce inlined interface
Date: Sat, 21 Mar 2015 00:17:08 -0400 (EDT)
Message-ID: <20150321.001708.185494440903517445.davem@davemloft.net>
References: <20150320222106.GA24241@gondor.apana.org.au>
	<20150320.183701.615035998227406804.davem@davemloft.net>
	<20150321031403.GA25793@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, eric.dumazet@gmail.com, kaber@trash.net,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbbCUERM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 00:17:12 -0400
In-Reply-To: <20150321031403.GA25793@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 21 Mar 2015 14:14:03 +1100

> netlink: Remove netlink_compare_arg.trailer
> 
> Instead of computing the offset from trailer, this patch computes
> netlink_compare_arg_len from the offset of portid and then adds 4
> to it.  This allows trailer to be removed.
> 
> Reported-by: David Miller <davem@davemloft.net>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
