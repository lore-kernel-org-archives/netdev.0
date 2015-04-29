From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next,v3,1/1] hv_netvsc: introduce netif-msg into
 netvsc module
Date: Wed, 29 Apr 2015 14:45:39 -0400 (EDT)
Message-ID: <20150429.144539.270258012829964745.davem@davemloft.net>
References: <1430208317-25493-1-git-send-email-sixiao@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com,
	devel@linuxdriverproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sixiao@microsoft.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430208317-25493-1-git-send-email-sixiao@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sixiao@microsoft.com
Date: Tue, 28 Apr 2015 01:05:17 -0700

> From: Simon Xiao <sixiao@microsoft.com>
> 
> 1. Introduce netif-msg to netvsc to control debug logging output
> and keep msg_enable in netvsc_device_context so that it is
> kept persistently.
> 2. Only call dump_rndis_message() when NETIF_MSG_RX_ERR or above
> is specified in netvsc module debug param.
> In non-debug mode, in current code, dump_rndis_message() will not
> dump anything but it still initialize some local variables and
> process the switch logic which is unnecessary, especially in
> high network throughput situation.
> 
> Signed-off-by: Simon Xiao <sixiao@microsoft.com>
> Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>

Applied.
