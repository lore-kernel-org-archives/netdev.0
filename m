From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net v2 1/1] xfrm: Fix NETDEV_DOWN with IPSec offload
Date: Mon, 8 May 2017 13:50:08 +0200
Message-ID: <20170508115008.GC9813@secunet.com>
References: <20170508073934.28529-1-ilant@mellanox.com>
 <20170508073934.28529-2-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>,
        Boris Pismenny <borisp@mellanox.com>, <netdev@vger.kernel.org>
To: <ilant@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36454 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752942AbdEHLuV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 07:50:21 -0400
Content-Disposition: inline
In-Reply-To: <20170508073934.28529-2-ilant@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 08, 2017 at 10:39:34AM +0300, ilant@mellanox.com wrote:
> From: Ilan Tayari <ilant@mellanox.com>
> 
> Upon NETDEV_DOWN event, all xfrm_state objects which are bound to
> the device are flushed.
> 
> The condition for this is wrong, though, testing dev->hw_features
> instead of dev->features. If a device has non-user-modifiable
> NETIF_F_HW_ESP, then its xfrm_state objects are not flushed,
> causing a crash later on after the device is deleted.
> 
> Check dev->features instead of dev->hw_features.
> 
> Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
> Signed-off-by: Ilan Tayari <ilant@mellanox.com>

Applied, thanks Ilan!
