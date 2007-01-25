From: David Miller <davem@davemloft.net>
Subject: Re: owner-Match in 2.6.20-rc5 (fwd)
Date: Thu, 25 Jan 2007 14:01:49 -0800 (PST)
Message-ID: <20070125.140149.51518685.davem@davemloft.net>
References: <Pine.LNX.4.64.0701252121190.26664@blackhole.kfki.hu>
	<20070125.130111.26966608.davem@davemloft.net>
	<Pine.LNX.4.61.0701252206360.26335@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kadlec@blackhole.kfki.hu, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
To: jengelh@linux01.gwdg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030617AbXAYWBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 17:01:50 -0500
In-Reply-To: <Pine.LNX.4.61.0701252206360.26335@yvahk01.tjqt.qr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Date: Thu, 25 Jan 2007 22:07:07 +0100 (MET)

> 
> >> The report below was posted on the netfilter user list. Isn't there any 
> >> ill side effect by reverting the change?
> >
> >Performance regression :-(
> >
> >This optimization saves a whole handful of heavy atomic operations in
> >the packet transmit path of TCP.
> >
> >As I understand it, the owner-Match is not in the upstream tree, and
> >it's the only thing that cares, so I see no reason to cater for it.
> 
> For me, it's there.
> -rw-r--r-- 1 jengelh users 2247 Jan 25 21:37
> /erk/kernel/linux-2.6.20-rc6/net/ipv4/netfilter/ipt_owner.c

Ok, I'll see what I can do about this :-)
