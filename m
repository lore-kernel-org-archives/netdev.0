From: David Miller <davem@davemloft.net>
Subject: Re: Netlink socket leaks
Date: Mon, 04 May 2015 00:13:36 -0400 (EDT)
Message-ID: <20150504.001336.1763965924175585221.davem@davemloft.net>
References: <CANaxB-weCVV0eQqRMnH59psXavrckip+Wfep2gdGLiw9rz3B5g@mail.gmail.com>
	<CANaxB-zvU0St+TkniHu9AKsW0Pd_j3BK17EfzCB+ghmDC0U22g@mail.gmail.com>
	<20150503000428.GA16211@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: avagin@gmail.com, netdev@vger.kernel.org, ying.xue@windriver.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59585 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750707AbbEDENi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 00:13:38 -0400
In-Reply-To: <20150503000428.GA16211@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 3 May 2015 08:04:28 +0800

> ---8<---
> Subject: Revert "net: kernel socket should be released in init_net namespace"
> 
> This reverts commit c243d7e20996254f89c28d4838b5feca735c030d.
> 
> That patch is solving a non-existant problem while creating a
> real problem.  Just because a socket is allocated in the init
> name space doesn't mean that it gets hashed in the init name space.
> 
> When we unhash it the name space must be the same as the one
> we had when we hashed it.  So this patch is completely bogus
> and causes socket leaks.
> 
> Reported-by: Andrey Wagin <avagin@gmail.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
