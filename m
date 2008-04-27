From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.25: Weird IPv4 stack behaviour, IPv6 is fine
Date: Sun, 27 Apr 2008 16:26:20 -0700 (PDT)
Message-ID: <20080427.162620.221106869.davem@davemloft.net>
References: <20080427231411.GA5261@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: rmk@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44704
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752942AbYD0X0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 19:26:20 -0400
In-Reply-To: <20080427231411.GA5261@flint.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk@arm.linux.org.uk>
Date: Mon, 28 Apr 2008 00:14:11 +0100

> Lastly, in /proc/net/snmp on lists, I find:
> 
> Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
> Ip: 2 64 12771 0 0 0 0 0 5159 6262 9 0 2 8172 1363 2 922 0 5520
> 
> Note - InReceives = 12771, but InDelivers = 5159 - so roughly 50% of
> IPv4 packets were received but not delivered, which appears to tie up
> with the ping statistics.
> 
> Not sure what to make of this at the moment.  Any ideas?

The ReasmTimeout and ReasmFails look interesting.  Maybe it was the
namespace bits?

Pavel, could you take a quick look?

Thanks.
