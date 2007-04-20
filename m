From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/0] Re-try changes for PMTUDISC_PROBE
Date: Fri, 20 Apr 2007 15:55:42 -0700 (PDT)
Message-ID: <20070420.155542.132926912.davem@davemloft.net>
References: <11746948063923-git-send-email-jheffner@psc.edu>
	<4619FBEE.70103@trash.net>
	<4626C0BE.2050205@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: jheffner@psc.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36827
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1767305AbXDTWzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 18:55:39 -0400
In-Reply-To: <4626C0BE.2050205@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Wed, 18 Apr 2007 21:07:10 -0400

> This backs out the the transport layer MTU checks that don't work.  As a 
> consequence, I had to back out the PMTUDISC_PROBE patch as well.  These 
> patches should fix the problem with ipv6 that the transport layer change 
> tried to address, and re-implement PMTUDISC_PROBE.  I think this 
> approach is nicer than the last one, since it doesn't require a bit in 
> struct sk_buff.

Since I was rebasing net-2.6.22, here is what I did.  I simply
elided the two patches you backed out, then I'll add patch
3 and 4, the new one's, on top.

This will show up when I publish the rebased net-2.6.22 tree
which I hope will happen later this evening.

Thanks!
