From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV6] IPSEC: Omit redirect for tunnelled packet.
Date: Fri, 24 Aug 2007 23:32:42 -0700 (PDT)
Message-ID: <20070824.233242.119219540.davem@davemloft.net>
References: <11879501353034-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45135
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757418AbXHYGcn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:32:43 -0400
In-Reply-To: <11879501353034-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri, 24 Aug 2007 19:08:55 +0900

> IPv6 IPsec tunnel gateway incorrectly sends redirect to
> router or sender when network device the IPsec tunnelled packet
> is arrived is the same as the one the decapsulated packet
> is sent.
> 
> With this patch, it omits to send the redirect when the forwarding
> skbuff carries secpath, since such skbuff should be assumed as
> a decapsulated packet from IPsec tunnel by own.
> 
> It may be a rare case for an IPsec security gateway, however
> it is not rare when the gateway is MIPv6 Home Agent since
> the another tunnel end-point is Mobile Node and it changes
> the attached network.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Patch applied, thanks.
