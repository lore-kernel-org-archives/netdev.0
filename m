From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sun, 24 Aug 2008 17:50:26 -0700 (PDT)
Message-ID: <20080824.175026.237775292.davem@davemloft.net>
References: <1219585163.4698.43.camel@localhost>
	<20080824191905.GA3372@ami.dom.local>
	<20080824192734.GB3372@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752727AbYHYAub (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 20:50:31 -0400
In-Reply-To: <20080824192734.GB3372@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 24 Aug 2008 21:27:34 +0200

> On Sun, Aug 24, 2008 at 09:19:05PM +0200, Jarek Poplawski wrote:
> ...
> > Jamal, maybe I miss something, but this could be like this only with
> > default pfifo_fast qdiscs, which really are per dev hwqueue. Other
> > qdiscs, including prio, are per device, so with prio, if a band with
> > the highest priority is blocked it would be requeued blocking other
> > bands (hwqueues in Alexander's case).
> 
> And, actually, because of this, Alexander is right the prio_dequeue()
> can't work like this without any changes.

Yes it can, see my other response.  Only the higher priority
queues filling up can block lower priority traffic, and that
is fine.

