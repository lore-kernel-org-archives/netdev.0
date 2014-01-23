From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: Use the correct maximum TX DMA ring size
 for SFC9100
Date: Thu, 23 Jan 2014 13:41:45 -0800 (PST)
Message-ID: <20140123.134145.959979759670800287.davem@davemloft.net>
References: <52E128C4.7010806@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60565 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751971AbaAWVlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 16:41:46 -0500
In-Reply-To: <52E128C4.7010806@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Thu, 23 Jan 2014 14:35:48 +0000

> From: Ben Hutchings <bhutchings@solarflare.com>
> 
> As part of a workaround for a hardware erratum in the SFC9100 family
> (SF bug 35388), the TX_DESC_UPD_DWORD register address is also used
> for communicating with the event block, and only descriptor pointer
> values < 2048 are valid.
> 
> If the TX DMA ring size is increased to 4096 descriptors (which the
> firmware still allows) then we may write a descriptor pointer 
> value >= 2048, which has entirely different and undesirable effects!
> 
> Limit the TX DMA ring size correctly when this workaround is in
> effect.
> 
> Fixes: 8127d661e77f ('sfc: Add support for Solarflare SFC9100 family')
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied.
