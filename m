From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP cubic v2.2
Date: Tue, 04 Mar 2008 14:18:23 -0800 (PST)
Message-ID: <20080304.141823.238894086.davem@davemloft.net>
References: <20080228223148.01a7cbae@extreme>
	<00a801c87ad7$7db74820$4a580e98@ncsu2cc0c3fa00>
	<20080304115740.63f8fa7c@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rhee@eos.ncsu.edu, sha2@ncsu.edu, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36706
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753339AbYCDWSc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 17:18:32 -0500
In-Reply-To: <20080304115740.63f8fa7c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 4 Mar 2008 11:57:40 -0800

> We have updated CUBIC to fix some issues with slow increase in large BDP 
> networks. We also improved its convergence speed. The fix is in fact very 
> simple --  the window increase limit of smax during the window probing phase 
> (i.e., convex growth phase) is removed. We found that this does not affect 
> TCP friendliness, but only improves its scalability. We have run some tests 
> in our lab and also over the Internet path from NCSU to Japan. These results 
> can be seen from the following page:
> 
> 
> http://netsrv.csc.ncsu.edu/wiki/index.php/Intra_protocol_fairness_testing_with_linux-2.6.23.9
> http://netsrv.csc.ncsu.edu/wiki/index.php/RTT_fairness_testing_with_linux-2.6.23.9
> http://netsrv.csc.ncsu.edu/wiki/index.php/TCP_friendliness_testing_with_linux-2.6.23.9
> 
> Signed-off-by: Sangtae Ha <sha2@ncsu.edu>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I've applied this to net-2.6.26, thanks!
