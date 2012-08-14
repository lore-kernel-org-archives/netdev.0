From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix incorrect comment in netif_tx_stop_queue()
Date: Tue, 14 Aug 2012 14:46:23 -0700 (PDT)
Message-ID: <20120814.144623.1855051650444819552.davem@davemloft.net>
References: <1344869014-7110-1-git-send-email-shchepetkov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@ispras.ru
To: shchepetkov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344869014-7110-1-git-send-email-shchepetkov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Ilya Shchepetkov <shchepetkov@ispras.ru>
Date: Mon, 13 Aug 2012 18:43:34 +0400

> netif_stop_queue() can be called before register_netdev() because now
> TX queues are allocated inside alloc_netdev_mqs().
> 
> (since ed9af2e839c06c18f721da2c768fbb444c4a10e5 commit)
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Ilya Shchepetkov <shchepetkov@ispras.ru>

You're not changing a "comment", you're changing a kernel log message.

Have you actually triggered this condition?

I doubt it, and I'm not applying this patch.
