From: Brent Cook <bcook@bpointsys.com>
Subject: neighbor vs neighbour
Date: Thu, 25 Jun 2009 14:31:34 -0500
Message-ID: <200906251431.34677.bcook@bpointsys.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 65-36-7-9.static.grandenetworks.net ([65.36.7.9]:35883 "EHLO
	bpointsys.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758749AbZFYTcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 15:32:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was looking at netstat -6 -s to debug a routing issue, and noticed that the 
output is a little confusing. What's the difference between 'neighbor 
solicits' and 'neighbour solicits'. And yes, I've already hear the 'Atlantic 
Ocean' joke :) Is one TX vs RX?

<snip>
Icmp6:
    3206 ICMP messages received
    0 input ICMP message failed.
    2593 ICMP messages sent
    ICMP input histogram:
        destination unreachable: 39
        echo requests: 63
        group member reductions: 6
        router solicits: 190
        router advertisement: 2669
        neighbour solicits: 10
        neighbour advertisement: 229
        ICMP output histogram:
        destination unreachable: 115
        echo replies: 63
        Icmp6OutRouterAdvertisements: 1895
        neighbor solicits: 354
        neighbor advertisements: 6
</snip>
