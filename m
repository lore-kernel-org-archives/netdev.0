From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: force stats update in ethtool gstats
Date: Thu, 16 Apr 2009 17:57:11 -0700 (PDT)
Message-ID: <20090416.175711.06577763.davem@davemloft.net>
References: <49E7235C.4080601@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46746
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752307AbZDQA5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 20:57:22 -0400
In-Reply-To: <49E7235C.4080601@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Thu, 16 Apr 2009 14:23:56 +0200

> Force a statistics update when our ethtool gstats routine
> is called.  Otherwise, ethtool will continue to read stale
> stats until something forces an update by reading /proc/net/dev
> 
> This requires putting a lock around the stats update to guard
> against 2 threads (one via ethtool, and one via procfs)
> updating the stats at once.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

Applied.
