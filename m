From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: fix sparse warning
Date: Tue, 09 Dec 2014 23:18:32 -0500 (EST)
Message-ID: <20141209.231832.1296239522700612004.davem@davemloft.net>
References: <1418182101-7992-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755305AbaLJESe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 23:18:34 -0500
In-Reply-To: <1418182101-7992-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Wed, 10 Dec 2014 11:28:21 +0800

> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
> index 866d9c9..32bd4ad 100644
> --- a/include/linux/rculist.h
> +++ b/include/linux/rculist.h
> @@ -524,11 +524,11 @@ static inline void hlist_add_behind_rcu(struct hlist_node *n,

Again, changes to this file should not go through my tree.
