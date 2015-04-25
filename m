From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v2,1/1] hv_netvsc: introduce netif-msg into
 netvsc module
Date: Sat, 25 Apr 2015 15:48:35 -0400 (EDT)
Message-ID: <20150425.154835.1582262265647227722.davem@davemloft.net>
References: <1429900488-7302-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sixiao@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429900488-7302-1-git-send-email-sixiao@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sixiao@microsoft.com
Date: Fri, 24 Apr 2015 11:34:48 -0700

> +	net_device_ctx->msg_enable = netif_msg_init(debug, default_msg);
> +	if (netif_msg_probe(net_device_ctx))
> +		netdev_dbg(net, "netvsc msg_enable: %d",
> +			   net_device_ctx->msg_enable);
> +

I expect you to respin this and fix the newline problem.

Also, net-next is not open for submissions yet.
