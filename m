From: David Miller <davem@davemloft.net>
Subject: Re: [net] netlink: Reset portid after netlink_insert failure
Date: Sat, 16 May 2015 17:09:44 -0400 (EDT)
Message-ID: <20150516.170944.202404920989150129.davem@davemloft.net>
References: <20150516123242.GA683@gondor.apana.org.au>
	<20150516134007.GA1152@gondor.apana.org.au>
	<20150516135028.GA1271@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbbEPVJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 17:09:46 -0400
In-Reply-To: <20150516135028.GA1271@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 16 May 2015 21:50:28 +0800

> The commit c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink:
> eliminate nl_sk_hash_lock") breaks the autobind retry mechanism
> because it doesn't reset portid after a failed netlink_insert.
> 
> This means that should autobind fail the first time around, then
> the socket will be stuck in limbo as it can never be bound again
> since it already has a non-zero portid.
> 
> Fixes: c5adde9468b0 ("netlink: eliminate nl_sk_hash_lock") 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good, applied and queued up for -stable.

Thanks!
