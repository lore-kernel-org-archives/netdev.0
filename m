From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] Improve tracing at the driver/core
 boundary
Date: Tue, 14 Jan 2014 14:47:23 -0800 (PST)
Message-ID: <20140114.144723.957109797286173047.davem@davemloft.net>
References: <1389392139.2025.123.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaANWrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 17:47:24 -0500
In-Reply-To: <1389392139.2025.123.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 10 Jan 2014 22:15:39 +0000

> These patches add static tracpeoints at the driver/core boundary which
> record various skb fields likely to be useful for datapath debugging.
> On the TX side the boundary is where the core calls ndo_start_xmit, and
> on the RX side it is where any of the various exported receive functions
> is called.
> 
> The set of skb fields is mostly based on what I thought would be
> interesting for sfc.
> 
> These patches are basically the same as what I sent as an RFC in
> November, but rebased.  They now depend on 'net: core: explicitly select
> a txq before doing l2 forwarding', so please merge net into net-next
> before trying to apply them.  The first patch fixes a code formatting
> error left behind after that fix.

This looks great, series applied, thanks Ben.
