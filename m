From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 0/8] sfc and ethtool changes for 2.6.37
Date: Tue, 21 Sep 2010 14:58:27 -0700 (PDT)
Message-ID: <20100921.145827.112592957.davem@davemloft.net>
References: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752821Ab0IUV6H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 17:58:07 -0400
In-Reply-To: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 20 Sep 2010 19:40:56 +0100

> This series adds Ethernet-level filtering and explicit filter clearing
> to the ethtool RX n-tuple interface, and implements it in the sfc
> driver.
> 
> There is a cleanup patch on the end which is preparation for the
> following RFC patch series but is worthwhile anyway.
> 
> Ben Hutchings (8):
>   ethtool: Define RX n-tuple action to clear a rule
>   ethtool: Add Ethernet MAC-level filtering/steering
>   ethtool: Allocate register dump buffer with vmalloc()
>   sfc: Add filter table management
>   sfc: Implement the ethtool RX n-tuple control functions
>   sfc: Include RX IP filter table in register dump
>   sfc: Set net_device::num_rx_queues once we know the correct value
>   sfc: Clean up and correct comments on efx_monitor()

All applied except patch #7 as noted in the thread for that patch.

Thanks!
