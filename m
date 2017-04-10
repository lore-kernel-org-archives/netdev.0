From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 00/12] ftgmac100: Rework batch 3 - TX path
Date: Mon, 10 Apr 2017 16:04:17 -0400 (EDT)
Message-ID: <20170410.160417.1325099963902050953.davem@davemloft.net>
References: <20170410011526.4509-1-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51066 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752587AbdDJUEY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 16:04:24 -0400
In-Reply-To: <20170410011526.4509-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Mon, 10 Apr 2017 11:15:14 +1000

> This is version 2 of the third batch of updates to
> the ftgmac100 driver.
> 
> This one tackles the TX path of the driver. This provides the
> bulk of the performance improvements by adding support for
> fragmented sends along with a bunch of cleanups.
> 
> Version 2 fixes a patch splitting mistake and uses
> eth_skb_pad() (which uses skb_put_padto) to pad ethernet
> frames rather than skb_padto(), thus removing the need to
> also pad the packet headlen in a couple of places. 
> 
> Subsequent batches will add various features (ethtool functions,
> vlan offlan, ...) and cleanups.

Series applied, thanks Ben.
