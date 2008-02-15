From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: broken link-local multicast?
Date: Thu, 14 Feb 2008 23:58:50 -0800
Message-ID: <OFC0F61926.E02437A5-ON882573F0.002AA552-882573F0.002BD5F2@us.ibm.com>
References: <alpine.LRH.1.00.0802150928020.3621@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: md@linux.it, netdev@vger.kernel.org
To: Pekka Savola <pekkas@netcore.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:45789 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbYBOH66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2008 02:58:58 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1F7wkBZ024651
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 02:58:46 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1F7wo2v206992
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 00:58:50 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1F7wnch029683
	for <netdev@vger.kernel.org>; Fri, 15 Feb 2008 00:58:50 -0700
In-Reply-To: <alpine.LRH.1.00.0802150928020.3621@netcore.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pekka,
        I first thought the interface might be down when I saw this
one, except the interface route is present in the route list he shows
later. That's normally deleted when the interface is down.
        And a failure to be in the group just wouldn't answer--
shouldn't cause net unreachable (which is a failure to send it).

Marco,
        You called this a "firewall" -- do you get the same thing
when you have no iptables rules?

                                                +-DLS

