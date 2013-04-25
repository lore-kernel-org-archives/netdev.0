From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sfc: Fix naming of MTD partitions for FPGA bitfiles
Date: Thu, 25 Apr 2013 01:37:22 -0400 (EDT)
Message-ID: <20130425.013722.848700186463969063.davem@davemloft.net>
References: <1366666807.4016.18.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48205 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab3DYFhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 01:37:24 -0400
In-Reply-To: <1366666807.4016.18.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 22 Apr 2013 22:40:07 +0100

> efx_mcdi_get_board_cfg() uses a buffer for the firmware response that
> is only large enough to hold subtypes for the originally defined set
> of NVRAM partitions.  Longer responses are truncated, and we may read
> off the end of the buffer when copying out subtypes for additional
> partitions.  In particular, this can result in the MTD partition for
> an FPGA bitfile being named e.g. 'eth5 sfc_fpga:00' when it should be
> 'eth5 sfc_fpga:01'.  This means the firmware update tool (sfupdate)
> can't tell which bitfile should be written to the partition.
> 
> Correct the response buffer size.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> This fix is required for full support of boards with PTP hardware
> clocks.  Please apply to net and queue it up for stable (only needed for
> 3.8.y and/or 3.9.y, depending on when this gets to Linus).

Applied and queued up for -stable, thanks.
