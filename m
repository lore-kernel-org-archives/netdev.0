From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/8] [I/OAT] DMA memcpy subsystem
Date: Fri, 03 Mar 2006 17:40:48 -0800 (PST)
Message-ID: <20060303.174048.14793187.davem@davemloft.net>
References: <20060303214036.11908.10499.stgit@gitlost.site>
	<20060303214220.11908.75517.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750776AbWCDBkn@vger.kernel.org>
To: christopher.leech@intel.com
In-Reply-To: <20060303214220.11908.75517.stgit@gitlost.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Leech <christopher.leech@intel.com>
Date: Fri, 03 Mar 2006 13:42:20 -0800

> +static spinlock_t dma_list_lock;

Please use DEFINE_SPINLOCK().

> +static void dma_chan_free_rcu(struct rcu_head *rcu) {

Newline before the brace please.

> +static void dma_async_device_cleanup(struct kref *kref) {

Newline before the brace please.

> +struct dma_chan_percpu
> +{

Left brace on the same line as "struct dma_chan_percpu" please.

> +struct dma_chan
> +{

Similarly.

Otherwise this patch looks mostly ok.
