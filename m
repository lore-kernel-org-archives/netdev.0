From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 0/2] Improve tracing at the driver/core boundary
Date: Sat, 09 Nov 2013 15:20:16 -0500 (EST)
Message-ID: <20131109.152016.1689868833952780020.davem@davemloft.net>
References: <1381761552.1626.8.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757049Ab3KIUUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 15:20:18 -0500
In-Reply-To: <1381761552.1626.8.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 14 Oct 2013 15:39:12 +0100

> These patches add static tracpeoints at the driver/core boundary which
> record various skb fields likely to be useful for datapath debugging.
> On the TX side the boundary is where the core calls ndo_start_xmit, and
> on the RX side it is where any of the various exported receive functions
> is called.
> 
> The set of skb fields is mostly based on what I thought would be
> interesting for sfc, and may need to be augmented to be more general.

FWIW I think these changes are fine and a good idea, thanks for following
up on this Ben.
