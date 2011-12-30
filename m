From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Enable suspend when device is idle from boot.
Date: Fri, 30 Dec 2011 17:22:11 -0500 (EST)
Message-ID: <20111230.172211.188260740088628815.davem@davemloft.net>
References: <1325183594-8947-1-git-send-email-tbroch@chromium.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, romieu@fr.zoreil.com, netdev@vger.kernel.org
To: tbroch@chromium.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44588 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028Ab1L3WXS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2011 17:23:18 -0500
In-Reply-To: <1325183594-8947-1-git-send-email-tbroch@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Broch <tbroch@chromium.org>
Date: Thu, 29 Dec 2011 10:33:14 -0800

> The r8169 driver supports power management and correctly transitions
> from active to suspend when link transitions from connected to
> disconnected.  However, if link is not connected at boot the device
> remains active after the initial probe.
> 
> This change adds a check of the link status to the idle pm_op that
> will schedule a suspend if inactive.
> 
> Signed-off-by: Todd Broch <tbroch@chromium.org>

Francois, what would you like me to do with this patch?

Thanks.
