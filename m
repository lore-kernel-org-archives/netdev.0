From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] sfc: free multiple Rx buffers when required
Date: Sun, 31 May 2015 17:36:34 -0700 (PDT)
Message-ID: <20150531.173634.715933710937064845.davem@davemloft.net>
References: <55684CC2.2010202@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44206 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751553AbbFAAgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 20:36:35 -0400
In-Reply-To: <55684CC2.2010202@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Fri, 29 May 2015 12:25:54 +0100

> From: Daniel Pieczko <dpieczko@solarflare.com>
> 
> When Rx packet data must be dropped, all the buffers
> associated with that Rx packet must be freed. Extend
> and rename efx_free_rx_buffer() to efx_free_rx_buffers()
> and loop through all the fragments.
> By doing so this patch fixes a possible memory leak.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied, thanks.
