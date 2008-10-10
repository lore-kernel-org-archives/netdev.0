From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: IGMP sent to Foreign VLAN
Date: Sat, 11 Oct 2008 00:45:36 +0200
Message-ID: <m363o0m5m7.fsf@ursa.amorsen.dk>
References: <1223322707.24688.46.camel@deepthought.nh.local>
	<20081007.160702.189194318.davem@davemloft.net>
	<48EBF677.1060602@trash.net>
	<1223508896.24688.95.camel@deepthought.nh.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Jarod Neuner <j.neuner@networkharbor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([217.195.186.3]:41610 "EHLO
	gate1.ipvision.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbYJJWpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 18:45:47 -0400
In-Reply-To: <1223508896.24688.95.camel@deepthought.nh.local> (Jarod Neuner's message of "Wed\, 8 Oct 2008 18\:34\:56 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarod Neuner <j.neuner@networkharbor.com> writes:

> My original thought was to do something like this in net/core/dev.c
> using a method similar to handle_bridge or handle_macvlen.  So, if the
> packet doesn't get handled by the ptype_base list and IFF_ALLVLAN is
> set, then strip the header and let the packet through.  The sticky point
> would be whether or not this policy should be enabled by default, as it
> seems to be in other network stacks.

So if I tcpdump on the base device, IFF_ALLVLAN gets set and packets
from unknown VLAN's suddenly lose their VLAN headers? That's a
security problem.


/Benny

