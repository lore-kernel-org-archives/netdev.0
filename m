From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Mon, 25 Aug 2008 01:02:06 -0700 (PDT)
Message-ID: <20080825.010206.193700650.davem@davemloft.net>
References: <20080825060640.GA2633@ff.dom.local>
	<20080825.004825.193701182.davem@davemloft.net>
	<20080825075744.GC2633@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42997
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751158AbYHYICK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 04:02:10 -0400
In-Reply-To: <20080825075744.GC2633@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 25 Aug 2008 07:57:44 +0000

> On Mon, Aug 25, 2008 at 12:48:25AM -0700, David Miller wrote:
> > From: Jarek Poplawski <jarkao2@gmail.com>
> > Date: Mon, 25 Aug 2008 06:06:40 +0000
> > 
> > If we feed packets after the first one to the card, we would not
> > be implementing a FIFO.
> 
> Not necessarilly so: if separate flows are hashed to "their" hwqueues,
> a FIFO per flow would be still obeyed.

What appears on the wire is still going to be similar.

You have to subsequently ask if it's worth the complexity to do
what you seem to be proposing.

When a single hardware queue fills up, it's the SAME, semantically,
as when a unary TX queue of a traditional device fills up.

There is NO on the wire difference.  There will be NO performance
difference, because the device will have work to do as by definition
of one TX queue being full there are some packets queued up to
the device.
