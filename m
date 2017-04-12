From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/10] ftgmac100: Rework batch 4 - Misc
Date: Wed, 12 Apr 2017 10:19:34 -0400 (EDT)
Message-ID: <20170412.101934.2165788638655556260.davem@davemloft.net>
References: <20170412032710.17546-1-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45568 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751349AbdDLOTg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:19:36 -0400
In-Reply-To: <20170412032710.17546-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 12 Apr 2017 13:27:00 +1000

> This is v2 of the fourth batch of updates to the ftgmac100 driver.
> 
> This is a bunch of misc cleanups and fixes, such as properly
> disabling HW checksum generation on AST2400 where it's known
> to be broken and some chip init updates.
> 
> This also adds the ability to turn HW checksum on/off and
> configure the ring sizes via ethtool.
> 
> v2 Fixes patch 1/10 (NETIF_F_HW_CSUM conversion)
> 
> The next (and last) batch will add a few more "features" such
> as netpoll, multicast/promist, vlan offload...
> 

Series applied, thanks Benjamin.

I really like how you use the reset task to implement ring resizing.
