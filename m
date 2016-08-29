From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] amd-xgbe: Reset running devices after resume
 from hibernate
Date: Mon, 29 Aug 2016 00:26:44 -0400 (EDT)
Message-ID: <20160829.002644.1483422041950202286.davem@davemloft.net>
References: <1472199683-12098-1-git-send-email-james.morse@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, thomas.lendacky@amd.com
To: james.morse@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49400 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750888AbcH2E0q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 00:26:46 -0400
In-Reply-To: <1472199683-12098-1-git-send-email-james.morse@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Morse <james.morse@arm.com>
Date: Fri, 26 Aug 2016 09:21:23 +0100

> After resume from hibernate on arm64, any amd-xgbe devices that were
> running when we hibernated are reported as down, even when it is not.
> 
> Re-plugging the cables does not cause the interface to come back, the
> link must be marked as down then up via 'ip set link' using the serial
> console.
> 
> This happens because the device has been power-cycled and possibly
> re-initialised by firmware, whereas the driver's memory structures have
> been restored from the hibernate image and the two do not agree.
> 
> Schedule a restart of the device after powerup in case the world changed
> while we were asleep.
> 
> Signed-off-by: James Morse <james.morse@arm.com>

Applied.
