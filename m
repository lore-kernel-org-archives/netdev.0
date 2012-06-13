From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ethtool: Make more commands available to
 unprivileged processes
Date: Tue, 12 Jun 2012 18:52:40 -0700 (PDT)
Message-ID: <20120612.185240.1347679260905366274.davem@davemloft.net>
References: <1339542341.15266.3.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751561Ab2FMBwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2012 21:52:42 -0400
In-Reply-To: <1339542341.15266.3.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 13 Jun 2012 00:05:41 +0100

> 'Get' commands should generally not require CAP_NET_ADMIN, with
> the exception of those that expose internal state.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> The one command I'm not sure about is ETHTOOL_STATS.  It might reveal
> too much detail about network traffic.  That said, /proc/net/dev and
> /sys/class/net/*/statistics are already world-readable.

Applied, it just means we need to scrutinize what people put into the
stats a little bit more.
