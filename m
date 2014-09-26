From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] nf pull request for net
Date: Fri, 26 Sep 2014 16:21:56 -0400 (EDT)
Message-ID: <20140926.162156.451026088058162233.davem@davemloft.net>
References: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50870 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755431AbaIZUV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 16:21:59 -0400
In-Reply-To: <1411464288-18069-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 23 Sep 2014 11:24:43 +0200

> This series contains netfilter fixes for net, they are:
> 
> 1) Fix lockdep splat in nft_hash when releasing sets from the
>    rcu_callback context. We don't the mutex there anymore.
> 
> 2) Remove unnecessary spinlock_bh in the destroy path of the nf_tables
>    rbtree set type from rcu_callback context.
> 
> 3) Fix another lockdep splat in rhashtable. None of the callers hold
>    a mutex when calling rhashtable_destroy.
> 
> 4) Fix duplicated error reporting from nfnetlink when aborting and
>    replaying a batch.
> 
> 5) Fix a Kconfig issue reported by kbuild robot.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.
