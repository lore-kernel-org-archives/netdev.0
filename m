From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] nfp: set config bit (ifup/ifdown) on netdev
 open/close
Date: Tue, 25 Jul 2017 12:29:58 -0700 (PDT)
Message-ID: <20170725.122958.2257952323982979614.davem@davemloft.net>
References: <20170725075108.18537-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        dirk.vandermerwe@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752421AbdGYT37 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 15:29:59 -0400
In-Reply-To: <20170725075108.18537-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 25 Jul 2017 00:51:08 -0700

> From: Dirk van der Merwe <dirk.vandermerwe@netronome.com>
> 
> When a netdev (PF netdev or representor) is opened or closed, set the
> physical port config bit appropriately - which powers UP/DOWN the PHY
> module for the physical interface.
> 
> The PHY is powered first in the HW/FW configuration step when opening
> the netdev and again last in the HW/FW configuration step when closing
> the netdev.
> 
> This is only applicable when there is a physical port associated with
> the netdev and if the NSP support this. Otherwise we silently ignore
> this step.
> 
> The 'nfp_eth_set_configured' can actually return positive values -
> updated the function documentation appropriately.
> 
> Signed-off-by: Dirk van der Merwe <dirk.vandermerwe@netronome.com>
> Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied, thanks Jakub.
