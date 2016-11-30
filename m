From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: Remove unnecessary memset of stats in netdev
 private data
Date: Wed, 30 Nov 2016 14:26:45 -0500 (EST)
Message-ID: <20161130.142645.1470335853211330441.davem@davemloft.net>
References: <20161129133507.5008-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dougmill@linux.vnet.ibm.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40374 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753419AbcK3T0q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 14:26:46 -0500
In-Reply-To: <20161129133507.5008-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Tue, 29 Nov 2016 14:35:07 +0100

> The memory for netdev private data is allocated using kzalloc/vzalloc in
> alloc_netdev_mqs, thus there is no need to zero the stats portion of it
> again in the driver's probe function.
> 
> In any case, the size for the memset is wrong as the stats member is of
> type rtnl_link_stats64, not net_device_stats.
> 
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied, thanks.
