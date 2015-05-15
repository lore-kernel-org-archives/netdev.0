From: David Miller <davem@redhat.com>
Subject: Re: netlink: Kill bogus lock_sock in netlink_insert
Date: Fri, 15 May 2015 12:49:55 -0400 (EDT)
Message-ID: <20150515.124955.1765730151919172866.davem@redhat.com>
References: <20150514042151.GA5482@gondor.apana.org.au>
	<20150514055824.GB6058@gondor.apana.org.au>
	<20150514060230.GD6058@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44556 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753443AbbEOQt5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 12:49:57 -0400
In-Reply-To: <20150514060230.GD6058@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 14 May 2015 14:02:30 +0800

> On Thu, May 14, 2015 at 01:58:24PM +0800, Herbert Xu wrote:
>> 
>> This patch also removes a bogus socket lock introduced by that
>> very same patch.
> 
> This bogus socket lock is still there in the current tree.
> 
> ---8<---
> The commit c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink:
> eliminate nl_sk_hash_lock") added a lock_sock to netlink_insert
> with no justifications whatsoever.
> 
> This patch kills it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Eric, does this improve your benchmark?
