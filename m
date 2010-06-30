From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] ipv6: Clamp reported valid_lft to a minimum of 0
Date: Wed, 30 Jun 2010 10:28:55 -0700 (PDT)
Message-ID: <20100630.102855.146351413.davem@davemloft.net>
References: <1277588267.26161.300.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, 514644@bugs.debian.org,
	piotr.lewandowski@gmail.com, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754988Ab0F3R2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 13:28:42 -0400
In-Reply-To: <1277588267.26161.300.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sat, 26 Jun 2010 22:37:47 +0100

> Since addresses are only revalidated every 2 minutes, the reported
> valid_lft can underflow shortly before the address is deleted.
> Clamp it to a minimum of 0, as for prefered_lft.
> 
> Reported-by: Piotr Lewandowski <piotr.lewandowski@gmail.com>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Applied to net-next-2.6
