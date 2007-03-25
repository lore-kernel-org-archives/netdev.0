From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Fix ipv6 round-robin locking
Date: Sat, 24 Mar 2007 18:15:29 -0700 (PDT)
Message-ID: <20070324.181529.74749053.davem@davemloft.net>
References: <20070324.124436.104040932.davem@davemloft.net>
	<20070324234030.GG521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46265
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753224AbXCYBPa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Mar 2007 21:15:30 -0400
In-Reply-To: <20070324234030.GG521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Sun, 25 Mar 2007 00:40:30 +0100

> Seondly, I'm not sure I've fully understood why this round robin mechanism
> is needed to ensure as many routers as possible are probed as soon as
> possible.
 ...
> I'm just making sure we know what we're doing :-)

Ignore rt6_probe(), pretend that it's disabled.

It's the neigh probe that occurs when we _return_ and
_use_ the route for something that elicits the probe
we are interested in.
