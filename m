From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 17/17] sfc: Create multiple TX queues
Date: Wed, 28 Apr 2010 12:46:50 -0700 (PDT)
Message-ID: <20100428.124650.15262737.davem@davemloft.net>
References: <1272482722.2549.17.camel@achroite.uk.solarflarecom.com>
	<1272483043.2549.33.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49157
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932106Ab0D1Tqo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 15:46:44 -0400
In-Reply-To: <1272483043.2549.33.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 28 Apr 2010 20:30:43 +0100

> Create a core TX queue and 2 hardware TX queues for each channel.
> If separate_tx_channels is set, create equal numbers of RX and TX
> channels instead.
> 
> Rewrite the channel and queue iteration macros accordingly.
> Eliminate efx_channel::used_flags as redundant.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
