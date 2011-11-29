From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix skb_update_prio
Date: Tue, 29 Nov 2011 18:25:58 -0500 (EST)
Message-ID: <20111129.182558.1550247306028343406.davem@davemloft.net>
References: <igorm@etf.rs>
	<1322243094-10420-1-git-send-email-igorm@etf.rs>
	<1322243094-10420-2-git-send-email-igorm@etf.rs>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: igorm@etf.rs
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44466 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756425Ab1K2X0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 18:26:04 -0500
In-Reply-To: <1322243094-10420-2-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: igorm@etf.rs
Date: Fri, 25 Nov 2011 18:44:54 +0100

> From: Igor Maravic <igorm@etf.rs>
> 
> Change function rcu_dereference to rcu_dereference_bh to avoid warning
> 
> [ INFO: suspicious RCU usage. ]
> -------------------------------
> net/core/dev.c:2459 suspicious rcu_dereference_check() usage!
> 
> because we are locking with
> 
> rcu_read_lock_bh();
> 
> in function dev_queue_xmit(struct sk_buff *skb)
> 
> Signed-off-by: Igor Maravic <igorm@etf.rs>

Applied, thanks.
