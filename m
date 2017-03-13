From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netvsc: handle select_queue when device is being
 removed
Date: Sun, 12 Mar 2017 23:14:07 -0700 (PDT)
Message-ID: <20170312.231407.361708590104485445.davem@davemloft.net>
References: <20170309225829.6051-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, netdev@vger.kernel.org,
        sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53224 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdCMGOJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 02:14:09 -0400
In-Reply-To: <20170309225829.6051-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu,  9 Mar 2017 14:58:29 -0800

> Move the send indirection table from the inner device (netvsc)
> to the network device context.
> 
> It is possible that netvsc_device is not present (remove in progress).
> This solves potential use after free issues when packet is being
> created during MTU change, shutdown, or queue count changes.
> 
> Fixes: d8e18ee0fa96 ("netvsc: enhance transmit select_queue")
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
> Needed only for 4.11 and net-next.

Applied.
