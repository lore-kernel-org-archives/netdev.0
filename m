From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: pktgen patch available for perusal.
Date: Wed, 1 Nov 2006 18:14:22 +0100
Message-ID: <17736.54766.657083.873206@robur.slu.se>
References: <45468F2E.4060809@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:23533 "EHLO mx1.slu.se")
	by vger.kernel.org with ESMTP id S2992683AbWKAROb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 12:14:31 -0500
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <45468F2E.4060809@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ben Greear writes:
 > I've completed the first pass of my changes to pktgen in 2.6.18.
 > Many of these features are probably DOA based on previous conversations,
 > but perhaps this will help someone....

 Thanks. Well sometimes there is a need to capture and drop pkts and various 
 points, so it handy to have code fragments ready and just add the hook when 
 it's needed in driver or rx softirq etc.

 > Changes:
 > * use a nano-second timer based on the scheduler timer (TSC) for relative times, instead of get_time_of_day.

 Any chance you extract this one so we can compare with get_time_of_day. This pops up
 in the profiles and TX numbers are not what used to be.

 Cheers.
					--ro
