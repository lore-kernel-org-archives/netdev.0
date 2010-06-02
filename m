From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] IP: Increment INADDRERRORS if routing for a packet is
 not successful
Date: Wed, 2 Jun 2010 11:35:12 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1006021131350.30182@router.home>
References: <alpine.DEB.2.00.1006011609280.9438@router.home>  <1275430054.2638.115.camel@edumazet-laptop>  <alpine.DEB.2.00.1006021025200.30182@router.home>  <1275492754.2725.192.camel@edumazet-laptop>  <alpine.DEB.2.00.1006021103410.30182@router.home>
 <1275496088.2725.202.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi157.sbcis.sbc.com ([207.115.36.171]:48968 "EHLO
	nlpi157.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932706Ab0FBQfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 12:35:15 -0400
In-Reply-To: <1275496088.2725.202.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Jun 2010, Eric Dumazet wrote:

> Your patch has nothing to do with dropped packets because of rp_filter.
>
> You inserted a counter increment in a path that is not taken at all by
> packet delivery.
>
> Maybe I missed something really obvious with your patch ?

rp_filter rejects a route and packets are dropped then.

> Have you considered CONFIG_NET_DROP_MONITOR ?
> This one catches all possible cases, a developper doesnt have to patch
> his kernel to add SNMP counters everywhere...

Just looking at it. Great. A hook into skb_free. That will do.
