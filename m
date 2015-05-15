From: David Miller <davem@redhat.com>
Subject: Re: netlink: Disable insertions/removals during rehash
Date: Fri, 15 May 2015 13:02:57 -0400 (EDT)
Message-ID: <20150515.130257.1322224469755323983.davem@redhat.com>
References: <20150514041628.GA5428@gondor.apana.org.au>
	<20150514042151.GA5482@gondor.apana.org.au>
	<20150514055824.GB6058@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34024 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753430AbbEORC6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 13:02:58 -0400
In-Reply-To: <20150514055824.GB6058@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 14 May 2015 13:58:24 +0800

> The current rhashtable rehash code is buggy and can't deal with
> parallel insertions/removals without corrupting the hash table.
> 
> This patch disables it by partially reverting
> c5adde9468b0714a051eac7f9666f23eb10b61f7 ("netlink: eliminate
> nl_sk_hash_lock").
> 
> This patch also removes a bogus socket lock introduced by that
> very same patch.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Herbert, if you agree with me in the other thread that the lock_sock()
or something like it has to remain, you'll need to respin this.

Thanks.
