From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] UDP: Make use of inet_iif() when doing socket lookups.
Date: Tue, 23 Oct 2007 20:26:04 -0700 (PDT)
Message-ID: <20071023.202604.71091476.davem@davemloft.net>
References: <471E403A.7040705@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58239
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753289AbXJXD0U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:26:20 -0400
In-Reply-To: <471E403A.7040705@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 23 Oct 2007 14:40:58 -0400

> UDP currently uses skb->dev->ifindex which may provide the wrong
> information when the socket bound to a specific interface.
> This patch makes inet_iif() accessible to UDP and makes UDP use it.
> 
> The scenario we are trying to fix is when a client is running on
> the same system and the server and both client and server bind to
> a non-loopback device.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

David, could you take a quick look at this one?

I have a hunch that this will have side-effects for multicast
applications and I'd feel better if you went over this patch
with that in mind.

Thanks!
