From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Sun, 20 Jul 2008 10:25:34 -0700 (PDT)
Message-ID: <20080720.102534.246150854.davem@davemloft.net>
References: <1216387641.4833.96.camel@localhost>
	<20080718.140539.122169028.davem@davemloft.net>
	<1216566963.4847.81.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48589
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758024AbYGTRZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 13:25:35 -0400
In-Reply-To: <1216566963.4847.81.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sun, 20 Jul 2008 11:16:03 -0400

> IMO, in the case of multiple hardware queues per physical wire,
> and such a netdevice already has a built-in hardware scheduler (they all
> seem to have this feature) then if we can feed the hardware queues
> directly, theres no need for any intermediate buffer(s).
> In such a case, to compare with qdisc arch, its like the root qdisc is
> in hardware.

They tend to implement round-robin or some similar fairness algorithm
amongst the queues, with zero concern about packet priorities.

It really is just like a bunch of queues to the phsyical layer,
fairly shared.

These things are built for parallelization, not prioritization.
