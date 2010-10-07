From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] igb: update adapter stats when reading
 /proc/net/dev.
Date: Wed, 06 Oct 2010 23:36:11 -0700 (PDT)
Message-ID: <20101006.233611.68115178.davem@davemloft.net>
References: <20101005141833.20929.10943.stgit@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: hawk@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36808
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750978Ab0JGGfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Oct 2010 02:35:50 -0400
In-Reply-To: <20101005141833.20929.10943.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@comx.dk>
Date: Tue, 05 Oct 2010 16:18:33 +0200

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

I assume that the Intel folks will take care of integrating this
now that the locking is fixed.

Thanks.
