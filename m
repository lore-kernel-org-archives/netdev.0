From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3] ixgbe: Set MSI-X vectors to
 NOBALANCING and set affinity
Date: Wed, 18 Nov 2009 10:10:30 -0800 (PST)
Message-ID: <20091118.101030.22004862.davem@davemloft.net>
References: <20091021022713.32449.54868.stgit@localhost.localdomain>
	<20091021.215031.57955781.davem@davemloft.net>
	<F86E8680A7D9D74A99DC6345E35A69293E3D4171@orsmsx503.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, gospo@redhat.com,
	netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53462
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932174AbZKRSKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 13:10:14 -0500
In-Reply-To: <F86E8680A7D9D74A99DC6345E35A69293E3D4171@orsmsx503.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Date: Thu, 12 Nov 2009 11:12:22 -0800

> Jesse Brandeburg and I talked with Arjan yesterday regarding these patches.

Thanks for the update.

> We also discussed the need for irqbalance to distinguish between Rx
> and Tx queue vectors.  Right now, irqbalance can identify an
> interrupt belong to an Ethernet device, but it stops there.  It
> needs to also distinguish the directional vectors, and make sure to
> balance the right queue vector with its paired queue (i.e. make sure
> Tx queue 0's vector lines up with Rx queue 0's vector).

Why don't you just simply use the same MSI-X vector for both TX
queue 0 and RX queue 0, can't your hardware do that?

That's what I plan on doing in the NIU driver soon.
