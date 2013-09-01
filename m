From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc-next 2013-08-30
Date: Sat, 31 Aug 2013 22:28:57 -0400 (EDT)
Message-ID: <20130831.222857.845781578450355342.davem@davemloft.net>
References: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752139Ab3IAC3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Aug 2013 22:29:01 -0400
In-Reply-To: <1377833794.2552.26.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 30 Aug 2013 04:36:34 +0100

> 1. A little more refactoring.
> 2. Remove the unnecessary use of atomic_t that you pointed out.
> 3. Add support for starting or queueing firmware requests from atomic
> context.
> 4. Add hwmon support for additional sensors found on some new boards.
> 5. Add support for the EF10 controller architecture, the SFC9100 family
> and specifically the SFC9120 controller.

Pulled, thanks Ben.

Maybe you can get away with just doing "atomic_inc_return()" for the
MCDI sequence number bump and avoid the iface lock in those paths?

Just an idea.
