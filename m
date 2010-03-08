From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] socket: Merge getsockname and getpeername into a
 single function
Date: Mon, 08 Mar 2010 12:24:13 -0800 (PST)
Message-ID: <20100308.122413.158901144.davem@davemloft.net>
References: <20100304032612.GB9016@home.unix.ba>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kenan@unix.ba
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38882
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755750Ab0CHUXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Mar 2010 15:23:53 -0500
In-Reply-To: <20100304032612.GB9016@home.unix.ba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kenan Kalajdzic <kenan@unix.ba>
Date: Thu, 4 Mar 2010 04:26:13 +0100

> The code of getsockname is almost identical to getpeername. This patch removes
> duplicate code and merges both functions into a single common function.
> 
> Signed-off-by: Kenan Kalajdzic <kenan@unix.ba>

Since you still have to conditionalize things like the security
calls, this doesn't look any cleaner to me than what we have
there already.

I'm not applying this, sorry.
