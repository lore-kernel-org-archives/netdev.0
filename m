From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Fix potential crash on destroy in rhashtable_shrink
Date: Mon, 02 Feb 2015 19:19:48 -0800 (PST)
Message-ID: <20150202.191948.1745138515710019835.davem@davemloft.net>
References: <20150131093637.GA29106@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50187 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754072AbbBCDTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 22:19:49 -0500
In-Reply-To: <20150131093637.GA29106@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 31 Jan 2015 20:36:38 +1100

> The current being_destroyed check in rhashtable_expand is not
> enough since if we start a shrinking process after freeing all
> elements in the table that's also going to crash.
> 
> This patch adds a being_destroyed check to the deferred worker
> thread so that we bail out as soon as we take the lock.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next
