From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] virtio_net: use default napi weight by default
Date: Sat, 11 May 2013 17:41:02 -0700 (PDT)
Message-ID: <20130511.174102.1103003063710887591.davem@davemloft.net>
References: <1368165051-11476-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, eric.dumazet@gmail.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752720Ab3ELAlD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 May 2013 20:41:03 -0400
In-Reply-To: <1368165051-11476-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri, 10 May 2013 13:50:51 +0800

> Since commit 82dc3c63c692b1e1d5937(net: introduce NAPI_POLL_WEIGHT)

I corrected this to:

	commit 82dc3c63c692b1e1d5937 ("net: introduce NAPI_POLL_WEIGHT")

> we warn drivers when they use napi weight higher than NAPI_POLL_WEIGHT,
> but virtio_net still uses 128 by default. This patch makes its default
> value to NAPI_POLL_WEIGHT.
> 
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
