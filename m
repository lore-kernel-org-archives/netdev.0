From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Add close of RNDIS filter into
 change mtu call
Date: Wed, 15 Jul 2015 21:12:25 -0700 (PDT)
Message-ID: <20150715.211225.1168237758074370336.davem@davemloft.net>
References: <1436818156-13674-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1436818156-13674-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Mon, 13 Jul 2015 13:09:16 -0700

> The current change mtu call only stops tx before removing RNDIS filter.
> In case ringbufer is not empty, the rndis_filter_device_remove() may
> hang on removing the buffers.
> 
> This patch adds close of RNDIS filter before removing it, also a
> gradual waiting loop until the ring is empty. The change_mtu hang
> issue under heavy traffic is solved by this patch.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
