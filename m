From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc 2013-12-10
Date: Tue, 10 Dec 2013 21:21:10 -0500 (EST)
Message-ID: <20131210.212110.449595140641890973.davem@davemloft.net>
References: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53700 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750980Ab3LKCVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 21:21:11 -0500
In-Reply-To: <1386726714.1516.236.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 11 Dec 2013 01:51:54 +0000

>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.13
 ...
> Several fixes for the PTP hardware support added in 3.7:
> 1. Fix filtering of PTP packets on the TX path to be robust against bad
> header lengths.
> 2. Limit logging on the RX path in case of a PTP packet flood, partly
> from Laurence Evans.
> 3. Disable PTP hardware when the interface is down so that we don't
> receive RX timestamp events, from Alexandre Rames.
> 4. Maintain clock frequency adjustment when a time offset is applied.
> 
> Also fixes for the SFC9100 family support added in 3.12:
> 5. Take the RX prefix length into account when applying NET_IP_ALIGN,
> from Andrew Rybchenko.
> 6. Work around a bug that breaks communication between the driver and
> firmware, from Robert Stonehouse.
> 
> Please also queue these up for the appropriate stable branches.

Pulled and queued up for -stable, thanks.
