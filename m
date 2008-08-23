From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Sat, 23 Aug 2008 01:15:46 -0700 (PDT)
Message-ID: <20080823.011546.127201278.davem@davemloft.net>
References: <5f2db9d90808221701t4c576282m34a46999b76b6e83@mail.gmail.com>
	<20080822.174032.117057862.davem@davemloft.net>
	<5f2db9d90808221837h2f727478qf78bb6e6a2867802@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, hadi@cyberus.ca, jeffrey.t.kirsher@intel.com,
	jeff@garzik.org, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42423
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750787AbYHWIPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 04:15:47 -0400
In-Reply-To: <5f2db9d90808221837h2f727478qf78bb6e6a2867802@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Alexander Duyck" <alexander.duyck@gmail.com>
Date: Fri, 22 Aug 2008 18:37:51 -0700

> I thought about doing just that but then I realized that there would
> be a number of issues.
> 
> First if I just set the skb->queue_mapping for the packet without
> moving it to a qdisc dedicated to that tx queue I run into
> head-of-line issues since multiple qdiscs will stop if holding packets
> for a single tx queue that is full.  That is over come in this patch
> by the fact that each qdisc has a specific fifo per tx queue.

Such fifos could be configured using 'tc' commands just
as easily.

Look, I know what you're trying to do is possible with at
best minor tweaks.  So don't press your luck listing how
impossible it is :-)

