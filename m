From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net-next tree
Date: Mon, 09 May 2016 21:32:08 -0400 (EDT)
Message-ID: <20160509.213208.1216178823447582162.davem@davemloft.net>
References: <20160510112914.08f1a497@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35823 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754228AbcEJBcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 21:32:11 -0400
In-Reply-To: <20160510112914.08f1a497@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 10 May 2016 11:29:14 +1000

> Caused by commit
> 
>   e800072c18f0 ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")
> 
> which seems to have reversed some of the merge fixes in commit
> 
>   cba653210056 ("Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net")
> 
> But I am not reaaly sure what has happened here :-(
> 
> I tried to use the net-next tree from next-20160509 but that now has
> conflicts agains other changes, so I applied the following fix patch
> for today.
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 10 May 2016 11:20:23 +1000
> Subject: [PATCH] net-next: fix bad merge
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Thanks Stephen, I'll try to sort this out.
