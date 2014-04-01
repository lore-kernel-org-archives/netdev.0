From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] Call efx_set_channels() before
 efx->type->dimension_resources()
Date: Tue, 01 Apr 2014 16:27:26 -0400 (EDT)
Message-ID: <20140401.162726.1295372958571326874.davem@davemloft.net>
References: <533AACBA.3020807@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	ben@decadent.org.uk
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55196 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbaDAU11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 16:27:27 -0400
In-Reply-To: <533AACBA.3020807@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Tue, 1 Apr 2014 13:10:34 +0100

> From: Daniel Pieczko <dpieczko@solarflare.com>
> 
> When using the "separate_tx_channels=1" module parameter, the TX queues are
> initially numbered starting from the first TX-only channel number (after all the
> RX-only channels).  efx_set_channels() renumbers the queues so that they are
> indexed from zero.
> 
> On EF10, the TX queues need to be relabelled in this way before calling the
> dimension_resources NIC type operation, otherwise the TX queue PIO buffers can be
> linked to the wrong VIs when using "separate_tx_channels=1".
> 
> Added comments to explain UC/WC mappings for PIO buffers
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied and queued up for -stable.
