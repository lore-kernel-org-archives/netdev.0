From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Fix warnings in cxgb3
Date: Thu, 23 May 2013 00:04:19 -0700 (PDT)
Message-ID: <20130523.000419.2227491126781427282.davem@davemloft.net>
References: <1369146089-19060-1-git-send-email-vipul@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, divy@chelsio.com, dm@chelsio.com,
	santosh@chelsio.com, fenlason@redhat.com
To: vipul@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417Ab3EWHEU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 May 2013 03:04:20 -0400
In-Reply-To: <1369146089-19060-1-git-send-email-vipul@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vipul Pandya <vipul@chelsio.com>
Date: Tue, 21 May 2013 19:51:27 +0530

> The first warning is about using rcu_dereference() when not in a rcu-locked
> section. It only happens on initialization hence fix the initialization to not
> rcu_dereference().
> 
> The second warning is about not checking that a *dma_map*() call succeeded.
> This patch adds checks at approprate places.
> 
> We request this patch series to get merged via net-next tree.

All applied, thanks.
