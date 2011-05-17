From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net: use hlist_del_rcu() in dev_change_name()
Date: Tue, 17 May 2011 13:57:32 -0400 (EDT)
Message-ID: <20110517.135732.2291351988531572448.davem@davemloft.net>
References: <1305649260.2850.106.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755745Ab1EQR5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 13:57:37 -0400
In-Reply-To: <1305649260.2850.106.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 May 2011 18:21:00 +0200

> Using plain hlist_del() in dev_change_name() is wrong since a
> concurrent reader can crash trying to dereference LIST_POISON1.
> 
> Bug introduced in commit 72c9528bab94 (net: Introduce
> dev_get_by_name_rcu())
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks.
