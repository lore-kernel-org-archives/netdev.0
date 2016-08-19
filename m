From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: avoid division by zero
Date: Thu, 18 Aug 2016 23:28:38 -0700 (PDT)
Message-ID: <20160818.232838.1658333345222256560.davem@davemloft.net>
References: <c09b487a-af9d-be97-c32d-dd06323bc0c8@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
        bkenward@solarflare.com
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42403 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750879AbcHSG2i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:28:38 -0400
In-Reply-To: <c09b487a-af9d-be97-c32d-dd06323bc0c8@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 17 Aug 2016 16:00:10 +0100

> The division is already being done properly in efx_ef10_get_timer_config
> which returns zero-on-success, unlike the old efx_ef10_get_sysclk_freq.
> 
> Fixes: d95e329a55ba ("sfc: get timer configuration from adapter")
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied.
