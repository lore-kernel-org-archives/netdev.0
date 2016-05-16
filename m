From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] sched,mlx5: Offloaded TC flower filter
 statistics
Date: Mon, 16 May 2016 13:44:08 -0400 (EDT)
Message-ID: <20160516.134408.547753707515208595.davem@davemloft.net>
References: <1463144142-13810-1-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com, saeedm@mellanox.com
To: amir@vadai.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36742 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754415AbcEPRoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:44:11 -0400
In-Reply-To: <1463144142-13810-1-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>
Date: Fri, 13 May 2016 12:55:34 +0000

> This patchset introduces counters support for offloaded cls_flower filters.
> When the user calls 'tc show -s ..', fl_dump is called.
> Before fl_dump() returns the statistics, it calls the NIC driver (using a new
> ndo_setup_tc() command - TC_CLSFLOWER_STATS) to read the hardware counters and
> update the statistics accordingly. A new TC action op was added (stats_update())
> to be used by the NIC driver to update the statistics.
> 
> Patchset was applied and tested over commit ed7cbbc ("udp: Resolve NULL pointer
> dereference over flow-based vxlan device")

Series applied, thanks.
