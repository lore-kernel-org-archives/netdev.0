From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: revert changes to NIC revision numbers
Date: Fri, 12 May 2017 12:34:23 -0400 (EDT)
Message-ID: <20170512.123423.875326676821100454.davem@davemloft.net>
References: <5a87b5cf-1696-0fbc-209d-95fa85023918@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35510 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756345AbdELQeY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 12:34:24 -0400
In-Reply-To: <5a87b5cf-1696-0fbc-209d-95fa85023918@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 12 May 2017 17:18:50 +0100

> From: Bert Kenward <bkenward@solarflare.com>
> 
> The revision enum values (eg EFX_REV_HUNT_A0) form part of our API,
>  and are included in ethtool. If these are inconsistent then ethtool
>  will print garbage for a register dump (ethtool -d).
> 
> Fixes: 5a6681e22c14 ("sfc: separate out SFC4000 ("Falcon") support into new sfc-falcon driver")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied.
