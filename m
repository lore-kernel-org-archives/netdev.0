From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Set MSI-X vectors to
 NOBALANCING and set affinity
Date: Wed, 18 Nov 2009 11:50:39 -0800 (PST)
Message-ID: <20091118.115039.41419484.davem@davemloft.net>
References: <F86E8680A7D9D74A99DC6345E35A69293E3D4171@orsmsx503.amr.corp.intel.com>
	<20091118.101030.22004862.davem@davemloft.net>
	<1258573570.2780.14.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peter.p.waskiewicz.jr@intel.com, jeffrey.t.kirsher@intel.com,
	gospo@redhat.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58958
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758065AbZKRTuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 14:50:22 -0500
In-Reply-To: <1258573570.2780.14.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 18 Nov 2009 19:46:10 +0000

> When forwarding between 2 ports it can be beneficial to match the
> affinity of each port's TX interrupts with the other port's RX
> interrupts.  Obviously this is not the case when the system is
> acting as an endpoint, and the situation is presumably more complex
> when forwarding between >2 ports.

Yes, but tricks like that won't be necessary with changes that Eric
Dumazet said he'd work on soon, wherein SKB frees always get scheduled
to occur on the cpu where allocation occured.

