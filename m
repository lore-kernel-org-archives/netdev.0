From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] sfc: allow ethtool selftest and MC reboot
 to complete on an unprivileged function
Date: Fri, 31 Jul 2015 15:32:16 -0700 (PDT)
Message-ID: <20150731.153216.813362621487824396.davem@davemloft.net>
References: <55BB4A9E.1090406@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51587 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750974AbbGaWcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 18:32:17 -0400
In-Reply-To: <55BB4A9E.1090406@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Fri, 31 Jul 2015 11:14:54 +0100

> From: Daniel Pieczko <dpieczko@solarflare.com>
> 
> The policy in the net driver is to attempt MCDI commands and
> then handle any EPERM error codes appropriately when returned
> by unprivileged functions.
> The ethtool selftest contains some tests which are useful on
> an unprivileged function, such as the event queue interrupt
> tests, but other tests cannot be performed as the function
> does not have the required permissions.
> 
> If a test returns -EPERM, act as though the test was not run
> and continue.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied.
