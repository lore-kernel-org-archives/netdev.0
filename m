From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.20.7 mss negotiation and path mtu discovery mostly broken?
Date: Thu, 03 May 2007 17:23:58 -0700 (PDT)
Message-ID: <20070503.172358.07643741.davem@davemloft.net>
References: <7CCD07160348804497EF29E9EA5560D7020F6213@exchtewks2.starentnetworks.com>
	<20070425.131602.18289973.davem@davemloft.net>
	<1178234660.4887.3.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bristuccia@starentnetworks.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54115
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423575AbXEDAX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 20:23:58 -0400
In-Reply-To: <1178234660.4887.3.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Thu, 03 May 2007 16:24:20 -0700

> [BNX2]: Fix TSO problem with small MSS.
> 
> Remove the check for skb->len greater than MTU when doing TSO.  When
> the destination has a smaller MSS than the source, a TSO packet may
> be smaller than the MTU at the source and we still need to process it
> as a TSO packet.
> 
> Thanks to Brian Ristuccia <bristuccia@starentnetworks.com> for
> reporting the problem.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
