From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] ppp: Remove PPPOX_ZOMBIE socket state
Date: Fri, 20 Nov 2015 11:31:43 -0500 (EST)
Message-ID: <20151120.113143.1245084459937375038.davem@davemloft.net>
References: <cover.1447931252.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mostrows@earthlink.net, simon@farnz.org.uk
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759948AbbKTQbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2015 11:31:46 -0500
In-Reply-To: <cover.1447931252.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 19 Nov 2015 12:52:30 +0100

> Several issues have been found lately wrt. the PPPOX_ZOMBIE socket
> state. This state is now only set upon reception of a PADT to stop
> further transmissions. However this is redundant with the PADT
> workqueue mechanism introduced by 287f3a943fef ("pppoe: Use workqueue
> to die properly when a PADT is received").
> 
> We can thus simplify pppox socket state handling by getting rid of
> PPPOX_ZOMBIE entirely.

Nice, applied to net-next, thanks!
