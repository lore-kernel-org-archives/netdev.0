From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 3/7] ixgbe: fix for 82599 erratum on Header Splitting.
Date: Thu, 27 Jan 2011 22:33:39 -0800 (PST)
Message-ID: <20110127.223339.226789576.davem@davemloft.net>
References: <1296195535-2990-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1296195535-2990-4-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: donald.c.skidmore@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, stable@kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44400
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753647Ab1A1GdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 01:33:04 -0500
In-Reply-To: <1296195535-2990-4-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 27 Jan 2011 22:18:51 -0800

> diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
> index 44a1cf0..1495b74 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -3176,9 +3176,16 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
>  	u32 mhadd, hlreg0;
>  
>  	/* Decide whether to use packet split mode or not */
> +	/* On by default */
> +	 adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
> +

Please fix this indentation, it's a TAB then a SPACE character.
