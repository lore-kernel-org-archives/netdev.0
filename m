From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: fix regression on Yukon Optima
Date: Fri, 04 Nov 2011 18:20:11 -0400 (EDT)
Message-ID: <20111104.182011.780847885736173054.davem@davemloft.net>
References: <201110171434.50436.pavel@netsafe.cz>
	<20111104151717.0f4666ac@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pavel@netsafe.cz, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753132Ab1KDWUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 18:20:17 -0400
In-Reply-To: <20111104151717.0f4666ac@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 4 Nov 2011 15:17:17 -0700

> Changes to support other Optima types, introduced an accidental
> regression that caused 88E8059 to come up in 10Mbit/sec.
> 
> The Yukon Optima supports a reverse auto-negotiation feature that
> was incorrectly setup, and not needed. The feature could be used to
> allow wake-on-lan at higher speeds. But doing it correctly would require
> other changes to initialization.
> 
> Reported-by: Pavel Mateja <pavel@netsafe.cz>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> ---
> This version is for current driver organization (post 3.1).
> Same fix applies but to drivers/net/sky2.c in -stable.

Applied and queued up for -stable, thanks.
