From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: allow setting LRO independently of
 lower device
Date: Tue, 09 Dec 2014 16:00:48 -0500 (EST)
Message-ID: <20141209.160048.1159420484833054299.davem@davemloft.net>
References: <20141205190937.99BD6A0BB0@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141205190937.99BD6A0BB0@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri, 5 Dec 2014 17:05:49 +0100

> Since commit fbe168ba91f7 ("net: generic dev_disable_lro() stacked
> device handling"), dev_disable_lro() zeroes NETIF_F_LRO feature flag
> first for a macvlan device and then for its lower device. As an attempt
> to set NETIF_F_LRO to zero is ignored, dev_disable_lro() issues a
> warning and taints kernel.
> 
> Allowing NETIF_F_LRO to be set independently of the lower device
> consists of three parts:
> 
>   - add the flag to hw_features to allow toggling it
>   - allow setting it to 0 even if lower device has the flag set
>   - add the flag to MACVLAN_FEATURES to restore copying from lower
>     device on macvlan creation
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied, thanks.
