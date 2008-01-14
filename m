From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH 2/9] get rid of unused revision element
Date: Mon, 14 Jan 2008 12:44:32 +0100
Message-ID: <18315.19232.437801.553809@robur.slu.se>
References: <20080112064513.803976049@linux-foundation.org>
	<20080112064646.132747871@linux-foundation.org>
	<20080112.205059.223738374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, robert.olsson@its.uu.se,
	netdev@vger.kernel.org, stephen.hemminger@vyatta.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:59389 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754953AbYANLou (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 06:44:50 -0500
In-Reply-To: <20080112.205059.223738374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Miller writes:

 > > The revision element must of been part of an earlier design,
 > > because currently it is set but never used.
 > > 
 > > Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
 > 
 > I suspect Robert wanted to play around with some generation
 > ID optimizations but never got around to it.

 The idea was to have a selective flush of route cache entries when
 a fib insert/delete happened. From what I remember you added another/
 better solution. Just a list with route cache entries pointing to parent 
 route. So yes this was obsoleted by your/our effort to avoid total 
 flushing of the route cache. Unfinished work.
 
 According to  http://bgpupdates.potaroo.net/instability/bgpupd.html
 (last in page) we currently flush the route cache 2.80 times per second. 
 when using full Internet routing with Linux. Maybe we're forced to pick 
 up this thread again someday.

 Cheers.
					--ro
 
 
