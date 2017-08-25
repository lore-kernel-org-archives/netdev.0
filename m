From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] hv_netvsc: Fix rndis_filter_close error
 during netvsc_remove
Date: Thu, 24 Aug 2017 21:58:02 -0700 (PDT)
Message-ID: <20170824.215802.1672700206641648629.davem@davemloft.net>
References: <20170824185002.10213-1-haiyangz@exchange.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: haiyangz@microsoft.com, haiyangz@exchange.microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824185002.10213-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Date: Thu, 24 Aug 2017 11:50:02 -0700

> From: Haiyang Zhang <haiyangz@microsoft.com>
> 
> We now remove rndis filter before unregister_netdev(), which calls
> device close. It involves closing rndis filter already removed.
> 
> This patch fixes this error.
> 
> Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied.
