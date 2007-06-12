From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 23:17:40 +0200
Message-ID: <466F0D74.5030308@trash.net>
References: <466DEF9D.9070509@trash.net>	<1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net> <20070612.140240.00078635.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46404 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751578AbXFLVUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 17:20:41 -0400
In-Reply-To: <20070612.140240.00078635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 12 Jun 2007 15:21:54 +0200
> 
> 
>>So how do we move forward?
> 
> 
> We're going to put hw multiqueue support in, all of this discussion
> has been pointless, I just watch this thread and basically laugh at
> the resistence to hw multiqueue support :-)


It did help me understand the consequences of the different approaches.
I'm still in favour of putting the patches in, but I've hacked up a
small multiqueue simulator device and to my big surprise my testing
showed that Jamal's suggestion of using a single queue state seems to
work better than I expected. But I've been doing mostly testing of
the device itself up to now with very simple traffic patterns (mostly
just "flood all queues"), so I'll try to get some real results tomorrow.

