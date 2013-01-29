From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] vmxnet3: set carrier state properly on probe
Date: Tue, 29 Jan 2013 16:08:25 -0500
Message-ID: <20130129210825.GD14044@hmsreliant.think-freely.org>
References: <1359147253-7204-1-git-send-email-nhorman@tuxdriver.com>
 <1359484611-23860-1-git-send-email-nhorman@tuxdriver.com>
 <20130129.154430.2272042048726099861.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, pv-drivers@vmware.com,
	bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37219 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741Ab3A2VIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 16:08:32 -0500
Content-Disposition: inline
In-Reply-To: <20130129.154430.2272042048726099861.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 29, 2013 at 03:44:30PM -0500, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Tue, 29 Jan 2013 13:36:51 -0500
> 
> > vmxnet3 fails to set netif_carrier_off on probe, meaning that when an interface
> > is opened the __LINK_STATE_NOCARRIER bit is already cleared, and so
> > /sys/class/net/<ifname>/operstate remains in the unknown state.  Correct this by
> > setting netif_carrier_off on probe, like other drivers do.
> > 
> > Also, while we're at it, lets remove the netif_carrier_ok checks from the
> > link_state_update function, as that check is atomically contained within the
> > netif_carrier_[on|off] functions anyway
> > 
> > Tested successfully by myself
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> This doesn't apply to the current 'net' tree.  Please respin.
I based it off net-next.  I'll respin for net
Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
