From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Set tx_table to equal weight after
 subchannels open
Date: Sun, 29 Oct 2017 12:09:55 +0900 (KST)
Message-ID: <20171029.120955.1383584318182871587.davem@davemloft.net>
References: <20171027193638.17823-1-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171027193638.17823-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Fri, 27 Oct 2017 12:36:38 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> In some cases, like internal vSwitch, the host doesn't provide
> send indirection table updates. This patch sets the table to be
> equal weight after subchannels are all open. Otherwise, all workload
> will be on one TX channel.
> 
> As tested, this patch has largely increased the throughput over
> internal vSwitch.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied to net-next, thanks.
