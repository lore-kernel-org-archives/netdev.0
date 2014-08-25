From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: prevent of emerging cross-namespace symlinks
Date: Sun, 24 Aug 2014 18:28:42 -0700 (PDT)
Message-ID: <20140824.182842.1083967994418672720.davem@davemloft.net>
References: <1408703693-6265-1-git-send-email-git.user@gmail.com>
	<20140822.113039.520798752693024139.davem@davemloft.net>
	<1408749310-28622-1-git-send-email-git.user@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@redhat.com
To: git.user@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52126 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753180AbaHYB2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 21:28:43 -0400
In-Reply-To: <1408749310-28622-1-git-send-email-git.user@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexander Y. Fomichev" <git.user@gmail.com>
Date: Sat, 23 Aug 2014 03:15:10 +0400

> Code manipulating sysfs symlinks on adjacent net_devices(s)
> currently doesn't take into account that devices potentially
> belong to different namespaces.
> 
> This patch trying to fix an issue as follows:
> - check for net_ns before creating / deleting symlink.
>   for now only netdev_adjacent_rename_links and
>   __netdev_adjacent_dev_remove are affected, afaics
>   __netdev_adjacent_dev_insert implies both net_devs 
>   belong to the same namespace.
> - Drop all existing symlinks to / from all adj_devs before
>   switching namespace and recreate them just after.
> 
> Signed-off-by: Alexander Y. Fomichev <git.user@gmail.com>
 ...
> -	if (netdev_adjacent_is_neigh_list(dev, dev_list))
> +	if (netdev_adjacent_is_neigh_list(dev, dev_list) &&
> +		net_eq(dev_net(dev),dev_net(adj_dev)))

Please indent this properly.

For a multi-line conditional, the second and subsequent lines
should begin exactly at the first column after the openning
parenthesis of the first line.

You must use the appropriate number of TAB and SPACE characters
necessary to do so.

Thank you.
