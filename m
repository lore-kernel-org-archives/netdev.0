From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] gre: fix hard header destination address checking
Date: Thu, 04 Mar 2010 00:41:10 -0800 (PST)
Message-ID: <20100304.004110.255528335.davem@davemloft.net>
References: <1267624874-22326-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.teras@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36176
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754529Ab0CDIkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 03:40:51 -0500
In-Reply-To: <1267624874-22326-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Teras <timo.teras@iki.fi>
Date: Wed,  3 Mar 2010 16:01:13 +0200

> ipgre_header() can be called with zero daddr when the gre device is
> configured as multipoint tunnel and still has the NOARP flag set (which is
> typically cleared by the userspace arp daemon).  If the NOARP packets are
> not dropped, ipgre_tunnel_xmit() will take rt->rt_gateway (= NBMA IP) and
> use that for route look up (and may lead to bogus xfrm acquires).
> 
> The multicast address check is removed as sending to multicast group should
> be ok.  In fact, if gre device has a multicast address as destination
> ipgre_header is always called with multicast address.
> 
> Signed-off-by: Timo Teras <timo.teras@iki.fi>

Applied.
