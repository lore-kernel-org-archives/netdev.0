From: Bill Fink <billfink@mindspring.com>
Subject: Re: TCP timewait recycle/reuse for IPv6?
Date: Tue, 18 Mar 2008 01:27:39 -0400
Message-ID: <20080318012739.6a5c8602.billfink@mindspring.com>
References: <200803171818.17494.opurdila@ixiacom.com>
	<47DEADC1.1040908@hp.com>
	<200803172004.33246.opurdila@ixiacom.com>
	<20080317.121006.206760103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-masked.atl.sa.earthlink.net ([209.86.89.68]:45448 "EHLO
	elasmtp-masked.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756421AbYCRF1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2008 01:27:53 -0400
In-Reply-To: <20080317.121006.206760103.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 17 Mar 2008, David Miller wrote:

> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Mon, 17 Mar 2008 20:04:33 +0200
> 
> > While running the same traffic with IPv4, the timewait recyle/reuse
> > features kicks in and keeps the number of TIMEWAIT sockets to under
> > a 1000.
> 
> Timewait recycling should not be enabled if any of your connections
> could even potentially be going through a firewall or NAT box.
> In such cases, the invariants which are necessary for timewait
> recycling to be valid are not present and thus you could risk
> connection or data corruption.
> 
> Timewait recycling depends upon end systems really being end
> systems on a connection level.  With NAT, that is no longer
> true, as the NAT box will reuse the same port for different
> end nodes in subsequent connections.

I have this hope that as IPv6/IPSEC becomes more commonplace, perhaps
it can help get back to the original TCP/IP direct end system to
end system model of communication, and reduce the current need for
such unfortunately necessary kludges as NAT boxes.

						-Bill
