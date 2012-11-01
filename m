From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Enable PPS and PTP clocks automatically
Date: Thu, 01 Nov 2012 11:37:01 -0400 (EDT)
Message-ID: <20121101.113701.1219642954944154124.davem@davemloft.net>
References: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: giometti@enneenne.com, richardcochran@gmail.com,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755404Ab2KAPhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 11:37:16 -0400
In-Reply-To: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 1 Nov 2012 01:29:57 +0000

> There are a number of problems with PPS and PTP kconfig options:
> 
> 1. PPS and PTP_1588_CLOCK depend on EXPERIMENTAL, therefore so must the
>    clock drivers.  (And EXPERIMENTAL is deprecated.)
> 2. PTP_1588_CLOCK depends on PPS, so users or clock driver options must
>    explicitly select both.
> 3. In general, users have to enable too many options to get hardware
>    timestamps and PTP working.
> 4. Boolean options for clock drivers combined with net drivers can force
>    the PTP and PPS subsystems to be built-in unnecessarily.
> 
> This series changes the options as follows:
> 
> 1. Nothing depends on EXPERIMENTAL.
> 2. Only PTP_1588_CLOCK selects PPS.
> 3, 4. The boolean options are removed and the net driver options select
>    PTP_1588_CLOCK.  Where a net driver and associated clock driver are
>    separate modules, the clock driver remains optional but is default y.

Looks good, series applied, thanks.
