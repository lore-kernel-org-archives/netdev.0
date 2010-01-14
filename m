From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Wed, 13 Jan 2010 17:30:19 -0800 (PST)
Message-ID: <20100113.173019.57466924.davem@davemloft.net>
References: <20100112134153.27117.59960.stgit@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: hawk@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57973
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751501Ab0ANBaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 20:30:11 -0500
In-Reply-To: <20100112134153.27117.59960.stgit@firesoul.comx.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@comx.dk>
Date: Tue, 12 Jan 2010 14:41:53 +0100

> Network driver igb: Improve the accuracy of stats in /proc/net/dev, by
> updating the adapter stats when reading /proc/net/dev.  Currently the
> stats are updated by the watchdog timer every 2 sec, or when getting
> stats via ethtool -S.
> 
> A number of userspace apps read these /proc/net/dev stats every second,
> e.g. ifstat, which then gives a perceived very bursty traffic pattern,
> which is actually false.
> 
> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>

Intel folks, I assume you guys are going to integrate this.

Thanks.
