From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [Fwd: Re: [PATCH] Multicast packet reassembly can fail]
Date: Wed, 28 Oct 2009 13:22:51 -0700
Message-ID: <OFF3C0AE1C.0C392C88-ON8825765D.006F8D81-8825765D.006FF4C0@us.ibm.com>
References: <1256754339.3153.481.camel@linux-1lbu>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Eric Dumazet <eric.dumazet@gmail.com>, mhuth@mvista.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Steve Chen <schen@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:44465 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755256AbZJ1UXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 16:23:11 -0400
In-Reply-To: <1256754339.3153.481.camel@linux-1lbu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 10/28/2009 11:25:39 AM:

> I see the point you are making.  I assumed, probably incorrectly, that
> since eth0 and eth1 have different IP address.  I would get a complete
> series of fragments for each interface.  Perhaps, I should really be
> looking up the stack to see why packets were dropped.  Please correct me
> if I'm mistaken.  The normal behavior is that application should be
> receiving either 2 (scenario 1) or 1 (scenario 2) packets.

Steve,
        If you didn't join the group on both interfaces, you won't receive
two copies in the first place; the unjoined NIC won't deliver anything
up the stack that isn't in it's multicast address filter.

 +-DLS

