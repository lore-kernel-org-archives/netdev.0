From: David Miller <davem@davemloft.net>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Tue, 25 Aug 2009 12:08:02 -0700 (PDT)
Message-ID: <20090825.120802.83163076.davem@davemloft.net>
References: <alpine.DEB.1.10.0908250946520.5972@gentwo.org>
	<OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cl@linux-foundation.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	niv@linux.vnet.ibm.com, sri@linux.vnet.ibm.com
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36748
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756031AbZHYTHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2009 15:07:49 -0400
In-Reply-To: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Tue, 25 Aug 2009 12:03:58 -0700

> IP_OUTDISCARDS should count the packets IP dropped, not
> anything dropped at a lower layer (which, in general, it
> is not aware of). If you count these in multiple layers,
> then you don't really know who dropped it.

Right.

We are in danger of going from one extreme to the other.
Previously we lacked some drop detection capabilities
but now we've filled most of these holes and ON TOP of
all of that we have Neil's SKB drop tracer.

Let's not get carried away over-accounting this stuff.
