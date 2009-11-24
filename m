From: David Miller <davem@davemloft.net>
Subject: Re: NUMA and multiQ interation
Date: Tue, 24 Nov 2009 10:06:13 -0800 (PST)
Message-ID: <20091124.100613.240222762.davem@davemloft.net>
References: <65634d660911240904y294ea6fj4cf2e4ac757e619b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34362
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758156AbZKXSFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 13:05:55 -0500
In-Reply-To: <65634d660911240904y294ea6fj4cf2e4ac757e619b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 24 Nov 2009 09:04:41 -0800

> What is the expected interaction here, and would these results be
> typical?  If so, would this warrant the need to associate each RX
> queue to a numa node, instead of just the device?

Yes we are fully aware of this and discussed it at netconf this year, see
in particular:

http://vger.kernel.org/netconf2009_slides/netconf2009_numa_discussion.odp

PJ is also currently trying to pass upstream some changes such that these
NUMA allocation bits can be exported to userspace and thus irqbalanced
can pick IRQ targetting more intelligently when a driver allocates per-queue
memory resources on different NUMA nodes.  The thread discussing this has
been going active for the past few days, maybe you missed it.
