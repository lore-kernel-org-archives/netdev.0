From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Introduce API for sending work
 requests on ctrl queue via copy
Date: Thu, 30 Jun 2016 08:22:04 -0400 (EDT)
Message-ID: <20160630.082204.1957002173817318052.davem@davemloft.net>
References: <1467171079-27193-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751845AbcF3MWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 08:22:34 -0400
In-Reply-To: <1467171079-27193-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 29 Jun 2016 09:01:19 +0530

> If the ctrl queue is full, just follows current path by allocating an
> skb. If that fails then caller will just have to handle that case as
> before.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

I only want to see new interfaces added alongside the actual users
of these interfaces.

Otherwise I'm not applying the change.
