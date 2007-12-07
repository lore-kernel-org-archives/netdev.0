From: David Miller <davem@davemloft.net>
Subject: Re: [patch 5/6] ipv6 - make af_inet6 to check ip6_route_init
 return value
Date: Fri, 07 Dec 2007 00:44:39 -0800 (PST)
Message-ID: <20071207.004439.09626888.davem@davemloft.net>
References: <20071206135329.598202596@ICON-9-164-138-215.megacenter.de.ibm.com>
	<20071206140307.686276824@ICON-9-164-138-215.megacenter.de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, pekkas@netcore.fi, netdev@vger.kernel.org,
	benjamin.thery@bull.net
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60001
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751740AbXLGIok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 03:44:40 -0500
In-Reply-To: <20071206140307.686276824@ICON-9-164-138-215.megacenter.de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Thu, 06 Dec 2007 14:53:34 +0100

> The af_inet6 initialization function does not check the return code
> of the route initilization, so if something goes wrong, the protocol
> initialization will continue anyway.
> This patch takes into account the modification made in the different
> route's initialization subroutines to check the return value and to 
> make the protocol initialization to fail.
> 
> Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
> Acked-by: Benjamin Thery <benjamin.thery@bull.net>

Applied, thanks!
