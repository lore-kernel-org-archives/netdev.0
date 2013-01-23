From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tuntap: reduce memory using of queues
Date: Wed, 23 Jan 2013 13:47:36 -0500 (EST)
Message-ID: <20130123.134736.1854102244959594689.davem@davemloft.net>
References: <1358949553-30309-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com,
	dwmw2@infradead.org
To: jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40682 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab3AWSrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 13:47:39 -0500
In-Reply-To: <1358949553-30309-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Wang <jasowang@redhat.com>
Date: Wed, 23 Jan 2013 21:59:12 +0800

> A MAX_TAP_QUEUES(1024) queues of tuntap device is always allocated
> unconditionally even userspace only requires a single queue device. This is
> unnecessary and will lead a very high order of page allocation when has a high
> possibility to fail. Solving this by creating a one queue net device when
> userspace only use one queue and also reduce MAX_TAP_QUEUES to
> DEFAULT_MAX_NUM_RSS_QUEUES which can guarantee the success of
> the allocation.
> 
> Reported-by: Dirk Hohndel <dirk@hohndel.org>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David Woodhouse <dwmw2@infradead.org>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Applied.
