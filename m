From: David Miller <davem@davemloft.net>
Subject: Re: [v2 0/5] *** nps_enet fixups ***
Date: Sun, 23 Aug 2015 16:09:09 -0700 (PDT)
Message-ID: <20150823.160909.2083002924709478558.davem@davemloft.net>
References: <20150817.103607.1737876155019074073.davem@davemloft.net>
	<1440046805-24459-1-git-send-email-noamc@ezchip.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Alexey.Brodkin@synopsys.com, vgupta@synopsys.com, talz@ezchip.com
To: noamc@ezchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbbHWXJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 19:09:10 -0400
In-Reply-To: <1440046805-24459-1-git-send-email-noamc@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noam Camus <noamc@ezchip.com>
Date: Thu, 20 Aug 2015 08:00:00 +0300

> Change v2
> TX done is handled back with NAPI poll.
> 
> Change v1
> This patch set is a bunch of fixes to make nps_enet work correctly with
> all platforms, i.e. real device, emulation system, and simulation system.
> The main trigger for this patch set was that in our emulation system
> the TX end interrupt is "edge-sensitive" and therefore we cannot use the
> cause register since it is not sticky.
> Also:
> TX is handled during HW interrupt context and not NAPI job.
> race with TX done was fixed.
> added acknowledge for TX when device is "level sensitive".
> enable drop of control frames which is not needed for regular usage.
> 
> So most of this patch set is about TX handling, which is now more complete.

Series applied, thank you.
