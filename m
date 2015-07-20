From: David Miller <davem@davemloft.net>
Subject: Re: Revert "sit: Add gro callbacks to sit_offload"
Date: Mon, 20 Jul 2015 16:53:29 -0700 (PDT)
Message-ID: <20150720.165329.259656303413900871.davem@davemloft.net>
References: <20150720061459.GA12023@gondor.apana.org.au>
	<2740217.XDs18yAg2Z@stwm.de>
	<20150720095538.GA13740@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@stwm.de, netdev@vger.kernel.org, tom@herbertland.com,
	eric.dumazet@gmail.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756847AbbGTXxa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 19:53:30 -0400
In-Reply-To: <20150720095538.GA13740@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 20 Jul 2015 17:55:38 +0800

> This patch reverts 19424e052fb44da2f00d1a868cbb51f3e9f4bbb5 ("sit:
> Add gro callbacks to sit_offload") because it generates packets
> that cannot be handled even by our own GSO.
> 
> Reported-by: Wolfgang Walter <linux@stwm.de>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks Herbert.
