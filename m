From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] vmxnet3: set carrier state properly on probe
Date: Tue, 29 Jan 2013 15:44:30 -0500 (EST)
Message-ID: <20130129.154430.2272042048726099861.davem@davemloft.net>
References: <1359147253-7204-1-git-send-email-nhorman@tuxdriver.com>
	<1359484611-23860-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com,
	bhutchings@solarflare.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60057 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518Ab3A2Uoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:44:32 -0500
In-Reply-To: <1359484611-23860-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 29 Jan 2013 13:36:51 -0500

> vmxnet3 fails to set netif_carrier_off on probe, meaning that when an interface
> is opened the __LINK_STATE_NOCARRIER bit is already cleared, and so
> /sys/class/net/<ifname>/operstate remains in the unknown state.  Correct this by
> setting netif_carrier_off on probe, like other drivers do.
> 
> Also, while we're at it, lets remove the netif_carrier_ok checks from the
> link_state_update function, as that check is atomically contained within the
> netif_carrier_[on|off] functions anyway
> 
> Tested successfully by myself
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

This doesn't apply to the current 'net' tree.  Please respin.
