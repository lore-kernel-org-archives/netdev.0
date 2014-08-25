From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: prevent of emerging cross-namespace symlinks
Date: Mon, 25 Aug 2014 15:18:40 -0700 (PDT)
Message-ID: <20140825.151840.251699935053411845.davem@davemloft.net>
References: <20140822.113039.520798752693024139.davem@davemloft.net>
	<20140824.182842.1083967994418672720.davem@davemloft.net>
	<1408969605-5800-1-git-send-email-git.user@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vfalico@redhat.com
To: git.user@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38470 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039AbaHYWSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 18:18:41 -0400
In-Reply-To: <1408969605-5800-1-git-send-email-git.user@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexander Y. Fomichev" <git.user@gmail.com>
Date: Mon, 25 Aug 2014 16:26:45 +0400

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

Applied, thanks.
