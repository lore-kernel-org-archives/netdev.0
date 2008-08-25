From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 3/3] pkt_sched: restore multiqueue prio scheduler
Date: Mon, 25 Aug 2008 08:35:11 +0000
Message-ID: <20080825083511.GE2633@ff.dom.local>
References: <20080825060640.GA2633@ff.dom.local> <20080825.004825.193701182.davem@davemloft.net> <20080825075744.GC2633@ff.dom.local> <20080825.010206.193700650.davem@davemloft.net> <20080825082501.GD2633@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, jeff@garzik.org,
	netdev@vger.kernel.org, alexander.h.duyck@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:16956 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752957AbYHYIfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2008 04:35:18 -0400
Received: by ug-out-1314.google.com with SMTP id c2so473331ugf.37
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2008 01:35:17 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080825082501.GD2633@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 25, 2008 at 08:25:01AM +0000, Jarek Poplawski wrote:
...
> If with unary TX queue we had to fill one bigger queue (or all TX
> queues) before device stopped a qdisc, and with mq TX it's enough to
> have one TX filled to effectively stop a qdisc transmit, IMHO there
> should be a performance difference.

And we should probably consider some TX queue could be stopped for
other reasons, blocking all transmit with mq TX but not unary TX.

Jarek P.
