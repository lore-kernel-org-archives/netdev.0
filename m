From: David Miller <davem@davemloft.net>
Subject: Re: owner-Match in 2.6.20-rc5 (fwd)
Date: Fri, 26 Jan 2007 01:05:15 -0800 (PST)
Message-ID: <20070126.010515.41193111.davem@davemloft.net>
References: <Pine.LNX.4.61.0701252206360.26335@yvahk01.tjqt.qr>
	<20070125.140149.51518685.davem@davemloft.net>
	<Pine.LNX.4.61.0701252309200.17844@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kadlec@blackhole.kfki.hu, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
To: jengelh@linux01.gwdg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36306
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030839AbXAZJFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 04:05:23 -0500
In-Reply-To: <Pine.LNX.4.61.0701252309200.17844@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Date: Thu, 25 Jan 2007 23:14:49 +0100 (MET)

> People really depend on this. Much more than than pid/comm/smpunsafe stuff.
> For example, a web server [cgi enabled, etc.] which also runs squid,
> to force all webtraffic through it:
> 
> -A OUTPUT -p tcp --dport 80 -m owner ! --uid-owner
>   squid -j REDIRECT --to-ports 3128

FWIW I've simply reverted the change in question to fix this.
Will push to Linus soon.
