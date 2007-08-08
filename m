From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP: H-TCP maxRTT estimation at startup
Date: Tue, 07 Aug 2007 18:29:17 -0700 (PDT)
Message-ID: <20070807.182917.101870814.davem@davemloft.net>
References: <CA61FA76-2C22-4048-B7AC-1D8E9D94868C@nuim.ie>
	<20070803105756.2f41dc25@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: doug.leith@nuim.ie, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58152
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935182AbXHHB3R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 21:29:17 -0400
In-Reply-To: <20070803105756.2f41dc25@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 3 Aug 2007 10:57:56 +0100

> Small patch to H-TCP from Douglas Leith. 
> 
> Fix estimation of maxRTT.  The original code ignores rtt measurements
> during slow start (via the check tp->snd_ssthresh < 0xFFFF) yet this
> is probably a good time to try to estimate max rtt as delayed acking
> is disabled and slow start will only exit on a loss which presumably
> corresponds to a maxrtt measurement.  Second, the original code (via
> the check htcp_ccount(ca) > 3) ignores rtt data during what it
> estimates to be the first 3 round-trip times.  This seems like an
> unnecessary check now that the RCV timestamp are no longer used
> for rtt estimation.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.
