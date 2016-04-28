From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: at803x: only the AT8030 needs a hardware
 reset on link change
Date: Thu, 28 Apr 2016 16:48:45 -0400 (EDT)
Message-ID: <20160428.164845.489992418800962568.davem@davemloft.net>
References: <1461692658-1742-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	marek.belisko@gmail.com, ujhelyi.m@gmail.com, zonque@gmail.com
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339AbcD1Usr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 16:48:47 -0400
In-Reply-To: <1461692658-1742-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Tue, 26 Apr 2016 12:44:18 -0500

> Commit 13a56b44 ("at803x: Add support for hardware reset") added a
> work-around for a hardware bug on the AT8030.  However, the work-around
> was being called for all 803x PHYs, even those that don't need it.
> Function at803x_link_change_notify() checks to make sure that it only
> resets the PHY on the 8030, but it makes more sense to not call that
> function at all if it isn't needed.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>

Applied, thanks.
