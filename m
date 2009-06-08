From: David Miller <davem@davemloft.net>
Subject: Re: IPoIB: Fix multicast packet drops before join is complete
Date: Mon, 08 Jun 2009 14:29:27 -0700 (PDT)
Message-ID: <20090608.142927.122160930.davem@davemloft.net>
References: <alpine.DEB.1.10.0906050959380.23895@gentwo.org>
	<20090605.181613.147549237.davem@davemloft.net>
	<alpine.DEB.1.10.0906081117580.21954@gentwo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, netdev@vger.kernel.org, yosefe@Voltaire.COM
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44126
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753288AbZFHV3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2009 17:29:25 -0400
In-Reply-To: <alpine.DEB.1.10.0906081117580.21954@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Mon, 8 Jun 2009 11:20:31 -0400 (EDT)

> On Fri, 5 Jun 2009, David Miller wrote:
> 
>> It's fundamentally wrong.  You need some limit there.
> 
> Maybe we need a different approach but (since we are at the point of
> talking about categorical fundamentally wrong statements) its
> fundamentally wrong if the IPoIB layer works differently from a regular
> Ethernet NIC. They should work in the same way.

This I agree on.  When a multicast group is joined, the IPoIB layer
should block in some way until the subscription is fully available
for use.
