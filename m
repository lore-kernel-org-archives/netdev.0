From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] sfc: fully reset if MC_REBOOT event
 received without warm_boot_count increment
Date: Mon, 12 Oct 2015 05:35:42 -0700 (PDT)
Message-ID: <20151012.053542.2070340672205173627.davem@davemloft.net>
References: <56178B93.6020205@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbbJLMTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 08:19:47 -0400
In-Reply-To: <56178B93.6020205@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Fri, 9 Oct 2015 10:40:35 +0100

> From: Daniel Pieczko <dpieczko@solarflare.com>
> 
> On EF10, MC_CMD_VPORT_RECONFIGURE can cause a CODE_MC_REBOOT event
> to be sent to a function without incrementing the (adapter-wide)
> warm_boot_count.  In this case, the reboot is not detected by the
> loop on efx_mcdi_poll_reboot(), so prepare for recovery from an MC
> reboot anyway.  When this codepath is run, the MC has always just
> rebooted, so this recovery is valid.
> 
> The loop on efx_mcdi_poll_reboot() is still required for other MC
> reboot cases, so that actions in response to an MC reboot are
> performed, such as clearing locally calculated statistics.
> Siena NICs are unaffected by this change as the above scenario
> does not apply.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied, thanks.
