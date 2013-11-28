From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvtap: fix tx_dropped counting error
Date: Thu, 28 Nov 2013 18:32:52 -0500 (EST)
Message-ID: <20131128.183252.1826466962938354277.davem@davemloft.net>
References: <1385371144-11071-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mst@redhat.com, vyasevic@redhat.com, edumazet@google.com
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47416 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210Ab3K1Xcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:32:54 -0500
In-Reply-To: <1385371144-11071-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Mon, 25 Nov 2013 17:19:04 +0800

> After commit 8ffab51b3dfc54876f145f15b351c41f3f703195
> (macvlan: lockless tx path), tx stat counter were converted to percpu stat
> structure. So we need use to this also for tx_dropped in macvtap. Otherwise, the
> management won't notice the dropping packet in macvtap tx path.
> 
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Cc: Vlad Yasevich <vyasevic@redhat.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied, thanks Jason.
