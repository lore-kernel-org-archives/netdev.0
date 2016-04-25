From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Fix the list processing for
 network change event
Date: Sun, 24 Apr 2016 23:28:35 -0400 (EDT)
Message-ID: <20160424.232835.398576562369921201.davem@davemloft.net>
References: <1461280381-17530-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
	vkuznets@redhat.com, linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org
To: haiyangz@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461280381-17530-1-git-send-email-haiyangz@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Thu, 21 Apr 2016 16:13:01 -0700

> RNDIS_STATUS_NETWORK_CHANGE event is handled as two "half events" --
> media disconnect & connect. The second half should be added to the list
> head, not to the tail. So all events are processed in normal order.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

Applied, thanks.
