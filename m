From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Set MSI-X vectors to
 NOBALANCING and set affinity
Date: Wed, 18 Nov 2009 17:14:57 -0800
Message-ID: <1258593299.3103.0.camel@ppwaskie-mobl2>
References: <F86E8680A7D9D74A99DC6345E35A69293E3D4171@orsmsx503.amr.corp.intel.com>
	 <20091118.101030.22004862.davem@davemloft.net>
	 <1258573570.2780.14.camel@achroite.uk.solarflarecom.com>
	 <20091118.115039.41419484.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1649 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932103AbZKSBOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 20:14:50 -0500
In-Reply-To: <20091118.115039.41419484.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-11-18 at 11:50 -0800, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Wed, 18 Nov 2009 19:46:10 +0000
> 
> > When forwarding between 2 ports it can be beneficial to match the
> > affinity of each port's TX interrupts with the other port's RX
> > interrupts.  Obviously this is not the case when the system is
> > acting as an endpoint, and the situation is presumably more complex
> > when forwarding between >2 ports.
> 
> Yes, but tricks like that won't be necessary with changes that Eric
> Dumazet said he'd work on soon, wherein SKB frees always get scheduled
> to occur on the cpu where allocation occured.
> 

We actually just submitted a patch that pairs our Rx queue 0 and Tx
queue 0 (up until the number of queues) onto the same MSI-X interrupt.
Arjan had indicated though he'd still like to make irqbalance smart
enough to distinguish Rx and Tx from one another, regardless if the
drivers just move to queue pairs or not.  I don't care either way, since
my queues are now paired.

-PJ

