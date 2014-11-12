From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netlink: Properly unbind in error conditions.
Date: Wed, 12 Nov 2014 15:49:37 -0500 (EST)
Message-ID: <20141112.154937.1480047832882312411.davem@davemloft.net>
References: <20141113042410.013c5d044aa442a05832d6d9@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rgb@redhat.com
To: shimoda.hiroaki@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46507 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753362AbaKLUtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 15:49:39 -0500
In-Reply-To: <20141113042410.013c5d044aa442a05832d6d9@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Date: Thu, 13 Nov 2014 04:24:10 +0900

> Even if netlink_kernel_cfg::unbind is implemented the unbind() method is
> not called, because cfg->unbind is omitted in __netlink_kernel_create().
> And fix wrong argument of test_bit() and off by one problem.
> 
> At this point, no unbind() method is implemented, so there is no real
> issue.
> 
> Fixes: 4f520900522f ("netlink: have netlink per-protocol bind function return an error code.")
> Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>

Applied and queued up for -stable, thanks.
