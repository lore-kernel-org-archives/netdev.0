From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Fix race condition on Multi-Send
 Data field
Date: Mon, 14 Dec 2015 00:02:22 -0500 (EST)
Message-ID: <20151214.000222.959007472004329129.davem@davemloft.net>
References: <1449778775-14404-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449778775-14404-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Thu, 10 Dec 2015 12:19:35 -0800

> In commit 2a04ae8acb14 ("hv_netvsc: remove locking in netvsc_send()"), the
> locking for MSD (Multi-Send Data) field was removed. This could cause a
> race condition between RNDIS control messages and data packets processing,
> because these two types of traffic are not synchronized.
> This patch fixes this issue by sending control messages out directly
> without reading MSD field.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied.
