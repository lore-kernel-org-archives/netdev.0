From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24 1/1] sch_htb: fix "too many events" situation
Date: Mon, 18 Feb 2008 00:17:36 -0800 (PST)
Message-ID: <20080218.001736.124204016.davem@davemloft.net>
References: <E1JPn6W-0002J2-5x@luxik.cdi.cz>
	<20080217.232829.222344360.davem@davemloft.net>
	<47B93BE8.7010905@cdi.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org
To: devik@cdi.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36558
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753290AbYBRIQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2008 03:16:59 -0500
In-Reply-To: <47B93BE8.7010905@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Devera <devik@cdi.cz>
Date: Mon, 18 Feb 2008 09:03:52 +0100

> aha, ok, I'm not so informed about crossplatform issues.
> I was also thining about looking at jiffies value and stop once
> it is startjiffy+2, but with NO_HZ introduction, are jiffies
> still incremented ?

There should always be at least once cpu tasked with incrementing
jiffies.  Lots of stuff would break if not :-)

