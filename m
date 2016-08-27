From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: fix potential stack corruption from running
 past stat bitmask
Date: Fri, 26 Aug 2016 21:41:03 -0700 (PDT)
Message-ID: <20160826.214103.1359468105411763184.davem@davemloft.net>
References: <0798c3e7-d8a1-3826-204d-2cbb0375205d@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbcH0Elg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 00:41:36 -0400
In-Reply-To: <0798c3e7-d8a1-3826-204d-2cbb0375205d@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 26 Aug 2016 11:19:34 +0100

> From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>
> 
> On 32-bit systems, mask is only an array of 3 longs, not 4, so don't try
> to write to mask[3].
> Also include build-time checks in case the size of the bitmask changes.
> 
> Fixes: 3c36a2aded8c ("sfc: display vadaptor statistics for all interfaces")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied, thank you.
