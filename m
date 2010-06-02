From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] sfc changes for 2.6.36
Date: Wed, 02 Jun 2010 02:21:44 -0700 (PDT)
Message-ID: <20100602.022144.63047920.davem@davemloft.net>
References: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52129
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753497Ab0FBJVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 05:21:35 -0400
In-Reply-To: <1275426967.2114.25.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 01 Jun 2010 22:16:07 +0100

> The major feature here is RX buffer recycling, which improves
> performance on networks with heavy multicast traffic.  Other than that,
> there are various bug fixes and cleanup.
> 
> Ben.
> 
> Ben Hutchings (3):
>   sfc: Rename struct efx_mcdi_phy_cfg to efx_mcdi_phy_data
>   sfc: Only count bad packets in rx_errors
>   sfc: Get port number from CS_PORT_NUM, not PCI function number
> 
> Steve Hodgson (9):
>   sfc: Reschedule any resets scheduled inside efx_pm_freeze()
>   sfc: Workaround flush failures on Falcon B0
>   sfc: Synchronise link_advertising and wanted_fc on Siena
>   sfc: Wait for the link to stay up before running loopback selftest
>   sfc: Allow DRV_GEN events to be used outside of selftests
>   sfc: Remove efx_rx_queue::add_lock
>   sfc: Support only two rx buffers per page
>   sfc: Recycle discarded rx buffers back onto the queue
>   sfc: Allow shared pages to be recycled

ALl applied, thanks Ben.
