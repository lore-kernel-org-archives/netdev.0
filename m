From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 02 Jun 2010 09:19:09 -0700 (PDT)
Message-ID: <20100602.091909.113727983.davem@davemloft.net>
References: <alpine.DEB.2.00.1006021025200.30182@router.home>
	<1275492754.2725.192.camel@edumazet-laptop>
	<alpine.DEB.2.00.1006021103410.30182@router.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: cl@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50917
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932681Ab0FBQTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:19:00 -0400
In-Reply-To: <alpine.DEB.2.00.1006021103410.30182@router.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux-foundation.org>
Date: Wed, 2 Jun 2010 11:12:14 -0500 (CDT)

> Its important to know why drops occur (any drops for that matter, drops
> mean retransmit which means latency).

We know, that's why there is a networking tracepoint that allows you
to see where all drops occur. :-)

