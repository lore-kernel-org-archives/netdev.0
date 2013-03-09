From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers:net: Remove unnecessary OOM messages
 after netdev_alloc_skb
Date: Sat, 09 Mar 2013 16:11:42 -0500 (EST)
Message-ID: <20130309.161142.153533460204187265.davem@davemloft.net>
References: <6379afbec3439c45180956b06c13b02ce3c9f802.1362790535.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org,
	linux-arm-kernel@lists.infradead.org, linuxppc-dev@lists.ozlabs.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab3CIVLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 16:11:36 -0500
In-Reply-To: <6379afbec3439c45180956b06c13b02ce3c9f802.1362790535.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri,  8 Mar 2013 17:03:25 -0800

> Emitting netdev_alloc_skb and netdev_alloc_skb_ip_align OOM
> messages is unnecessary as there is already a dump_stack
> after allocation failures.
> 
> Other trivial changes around these removals:
> 
> Convert a few comparisons of pointer to 0 to !pointer.
> Change flow to remove unnecessary label.
> Remove now unused variable.
> Hoist assignment from if.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
