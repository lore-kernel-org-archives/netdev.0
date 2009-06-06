From: David Miller <davem@davemloft.net>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Fri, 05 Jun 2009 18:17:30 -0700 (PDT)
Message-ID: <20090605.181730.51590434.davem@davemloft.net>
References: <adaeitywrfj.fsf@cisco.com>
	<alpine.DEB.1.10.0906051444360.29918@gentwo.org>
	<adafxeev0zg.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, netdev@vger.kernel.org,
	yosefe@Voltaire.COM
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45814
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753455AbZFFBR3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 21:17:29 -0400
In-Reply-To: <adafxeev0zg.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 05 Jun 2009 14:12:35 -0700

> ethernet is a different L2 -- you don't have to resolve an IP multicast
> address to an L2 address the way you do for IPoIB.
> 
> My point is just that multicast group join is the same sort of L2
> resolution as ARP is for ethernet, and so having the same sort of
> behavior makes sense.

Then the IPoIB layer should block on group join, not have this
limitless packet backlog which as I have explained is ill designed
and definitely not futureproof.
