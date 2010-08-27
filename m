From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 1/2] qdisc: Allow qdiscs to provide backpressure up
 the stack.
Date: Thu, 26 Aug 2010 23:11:10 -0700 (PDT)
Message-ID: <20100826.231110.260096663.davem@davemloft.net>
References: <4C774B8F.2030805@candelatech.com>
	<20100826.223604.48516081.davem@davemloft.net>
	<4C775411.1000302@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50605
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753888Ab0H0GKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 02:10:54 -0400
In-Reply-To: <4C775411.1000302@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Thu, 26 Aug 2010 22:58:41 -0700

> And if it does that, then something must know how to restart the
> transmit logic.

When SKBs get freed up, space opens up in the socket send buffer,
waking up the process or signalling it from poll() so it can write
more.

pktgen eliminates this whole layer of queueing and signalling, which
is why it continually succeptible this behavior you dislike.
