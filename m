From: David Miller <davem@davemloft.net>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
 Qdisc changes and sch_rr added for multiqueue
Date: Sat, 30 Jun 2007 13:33:57 -0700 (PDT)
Message-ID: <20070630.133357.77057070.davem@davemloft.net>
References: <1183167053.5153.7.camel@localhost>
	<20070629.213503.34601850.davem@davemloft.net>
	<1183215164.5165.13.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49878
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752139AbXF3Udz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 16:33:55 -0400
In-Reply-To: <1183215164.5165.13.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Sat, 30 Jun 2007 10:52:44 -0400

> On Fri, 2007-29-06 at 21:35 -0700, David Miller wrote:
> 
> > Awesome, but let's concentrate on the client since I can actually
> > implement and test anything we come up with :-)
> 
> Ok, you need to clear one premise for me then ;->
> You said the model is for the guest/client to hook have a port to the
> host and one to each guest; i think this is the confusing part for me
> (and may have led to the switch discussion) because i have not seen this
> model used before. What i have seen before is that the host side
> connects the different guests. In such a scenario, on the guest is a
> single port that connects to the host - the host worries (lets forget
> the switch/bridge for a sec) about how to get packets from guestX to
> guestY pending consultation of access control details.
> What is the advantage of direct domain-domain connection? Is it a
> scalable?

It's like twice as fast, since the switch doesn't have to copy
the packet in, switch it, then the destination guest copies it
into it's address space.

There is approximately one copy for each hop you go over through these
virtual devices.
