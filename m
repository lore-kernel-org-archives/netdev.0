From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/7] net: ethernet: ti: cpsw: support placing CPDMA
 descriptors into DDR
Date: Sat, 07 Jan 2017 20:48:35 -0500 (EST)
Message-ID: <20170107.204835.280172002099890013.davem@davemloft.net>
References: <20170106200735.4210-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
        ivan.khoronzhuk@linaro.org, nsekhar@ti.com,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933164AbdAHBsh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 20:48:37 -0500
In-Reply-To: <20170106200735.4210-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Fri, 6 Jan 2017 14:07:28 -0600

> This series intended to add support for placing CPDMA descriptors into DDR by
> introducing new module parameter "descs_pool_size" to specify size of descriptor's
> pool. The "descs_pool_size" defines total number of CPDMA
> CPPI descriptors to be used for both ingress/egress packets
> processing. If not specified - the default value 256 will be used
> which will allow to place descriptor's pool into the internal CPPI
> RAM.
> 
> In addition, added ability to re-split CPDMA pool of descriptors between RX and TX
> path via ethtool '-G' command wich will allow to configure and fix number
> of descriptors used by RX and TX path, which, then, will be split between
> RX/TX channels proportionally depending on number of RX/TX channels and
> its weight. 
> 
> This allows significantly to reduce UDP packets drop rate
> for bandwidth >301 Mbits/sec (am57x).  
> 
> Before enabling this feature, the am437x SoC has to be fixed as it's proved
> that it's not working when CPDMA descriptors placed in DDR.
> So, the patch 1 fixes this issue.

Series applied to net-next, thanks.
