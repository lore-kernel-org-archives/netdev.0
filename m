From: David Miller <davem@davemloft.net>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
 Qdisc changes and sch_rr added for multiqueue
Date: Sat, 07 Jul 2007 23:03:00 -0700 (PDT)
Message-ID: <20070707.230300.74561917.davem@davemloft.net>
References: <1183515611.5174.34.camel@localhost>
	<1183707166.6005.172.camel@localhost.localdomain>
	<1183732755.5155.85.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, kaber@trash.net,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34401
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751897AbXGHGCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 02:02:38 -0400
In-Reply-To: <1183732755.5155.85.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Fri, 06 Jul 2007 10:39:15 -0400

> If the issue is usability of listing 1024 netdevices, i can think of
> many ways to resolve it.

I would agree with this if there were a reason for it, it's totally
unnecessary complication as far as I can see.

These virtual devices are an ethernet with the subnet details exposed
to the driver, nothing more.

I see zero benefit to having a netdev for each guest or node we can
speak to whatsoever.  It's a very heavy abstraction to use for
something that is so bloody simple.

My demux on ->hard_start_xmit() is _5 DAMN LINES OF CODE_, you want to
replace that with a full netdev because of some minor difficulties in
figuring out to record the queuing state.  It's beyond unreasonable.

Netdevs are like salt, if you put too much in your food it tastes
awful.
