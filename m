From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: limit the number of receive queues
Date: Mon, 17 Apr 2017 11:01:35 -0400 (EDT)
Message-ID: <20170417.110135.365969203734648464.davem@davemloft.net>
References: <08aae3d8-7ff9-a0f0-8432-2b7b1e026611@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.org, netdev@vger.kernel.org,
        linux-net-drivers@solarflare.com
To: bkenward@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751295AbdDQPBk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 11:01:40 -0400
In-Reply-To: <08aae3d8-7ff9-a0f0-8432-2b7b1e026611@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bert Kenward <bkenward@solarflare.com>
Date: Wed, 12 Apr 2017 17:06:52 +0100

> The number of rx queues is determined by the rss_cpus parameter
> or the cpu topology. If that is higher than EFX_MAX_RX_QUEUES the
> driver can corrupt state.
> 
> Fixes: 8ceee660aacb ("New driver "sfc" for Solarstorm SFC4000 controller.")
> Signed-off-by: Bert Kenward <bkenward@solarflare.com>

Applied, thank you.
