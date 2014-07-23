From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: Add support for busy polling
Date: Tue, 22 Jul 2014 19:55:32 -0700 (PDT)
Message-ID: <20140722.195532.1027160151425843015.davem@davemloft.net>
References: <53CE611D.7080109@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54015 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753988AbaGWCzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 22:55:36 -0400
In-Reply-To: <53CE611D.7080109@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Tue, 22 Jul 2014 14:03:25 +0100

> From: Alexandre Rames <arames@solarflare.com>
> 
> This patch adds the sfc driver code for implementing busy polling.
> It adds ndo_busy_poll method and locking between it and napi poll.
> It also adds each napi to the napi_hash right after netif_napi_add().
> 
> Uses efx_start_eventq and efx_stop_eventq in the self tests.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied, thanks.
