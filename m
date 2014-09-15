From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix creation adjacent device symlinks
Date: Mon, 15 Sep 2014 14:25:52 -0400 (EDT)
Message-ID: <20140915.142552.1309557030137895553.davem@davemloft.net>
References: <20140914.174507.2303420279405209295.davem@davemloft.net>
	<1410776555-29983-1-git-send-email-git.user@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cwang@twopensource.com, vyasevic@redhat.com
To: git.user@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123AbaIOSZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 14:25:54 -0400
In-Reply-To: <1410776555-29983-1-git-send-email-git.user@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Fomichev <git.user@gmail.com>
Date: Mon, 15 Sep 2014 14:22:35 +0400

> __netdev_adjacent_dev_insert may add adjust device of different net
> namespace, without proper check it leads to emergence of broken
> sysfs links from/to devices in another namespace.
> Fix: rewrite netdev_adjacent_is_neigh_list macro as a function,
>      move net_eq check into netdev_adjacent_is_neigh_list.
>      (thanks David)
>      related to: 4c75431ac3520631f1d9e74aa88407e6374dbbc4
> 
> Signed-off-by: Alexander Fomichev <git.user@gmail.com>

Applied, thanks.
