From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Revert "hv_netvsc: report vmbus name in ethtool"
Date: Sat, 29 Oct 2016 15:04:04 -0400 (EDT)
Message-ID: <20161029.150404.985532559704125284.davem@davemloft.net>
References: <20161026092753.1555a5ac@xeon-e3>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, vkuznets@redhat.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51850 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752319AbcJ2TEF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 15:04:05 -0400
In-Reply-To: <20161026092753.1555a5ac@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed, 26 Oct 2016 09:27:53 -0700

> From: Stephen Hemminger <sthemmin@microsoft.com>
> 
> This reverts commit e3f74b841d48
> ("hv_netvsc: report vmbus name in ethtool")'
> because of problem introduced by commit f9a56e5d6a0ba
> ("Drivers: hv: make VMBus bus ids persistent").
> This changed the format of the vmbus name and this new format is too
> long to fit in the bus_info field of ethtool.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>

Applied.
