From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] UDP: Make use of inet_iif() when doing socket lookups.
Date: Thu, 25 Oct 2007 18:55:19 -0700 (PDT)
Message-ID: <20071025.185519.51202916.davem@davemloft.net>
References: <471E403A.7040705@hp.com>
	<OFD4C47A22.AA67398C-ON8825737F.0077CEF6-8825737F.00789CCE@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46822
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758808AbXJZBzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2007 21:55:18 -0400
In-Reply-To: <OFD4C47A22.AA67398C-ON8825737F.0077CEF6-8825737F.00789CCE@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Stevens <dlstevens@us.ibm.com>
Date: Thu, 25 Oct 2007 14:58:29 -0700

> I don't see any problem with this. If you're using IP_MULTICAST_IF with
> a bound socket, it forces you to use that interface, anyway.
> 
> I'm not sure multicasting works as expected in some other cases with
> bound sockets (looks like there may be some holes to evade the
> binding), but that's in old code. I don't see any problems from this
> patch.
> 
>                                         +-DLS
> 
> Acked-by: David L Stevens <dlstevens@us.ibm.com>

Patch applied, thanks everyone!
