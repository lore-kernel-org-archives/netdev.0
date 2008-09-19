From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC PATCH] sched: only dequeue if packet can be queued to
	hardware queue.
Date: Fri, 19 Sep 2008 18:37:38 +0200
Message-ID: <20080919163738.GA2843@ami.dom.local>
References: <20080918063036.27934.91273.stgit@localhost.localdomain> <20080918194419.GA2982@ami.dom.local> <20080919151632.GB2646@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, kaber@trash.net
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:37705 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617AbYISQgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 12:36:43 -0400
Received: by ey-out-2122.google.com with SMTP id 6so163948eyi.37
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2008 09:36:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080919151632.GB2646@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2008 at 05:16:32PM +0200, Jarek Poplawski wrote:
...
> Alexander, I guess you've seen my last messages/patches in this thread
> and noticed that this __netif_schedule() problem is present both in
> this RFC patch and sch_multiq: if skb isn't dequeued because of inner
> tx_queue stopped state check, there is missing __netif_schedule()
> before exit from qdisc_run().

Hmm... probably false alarm. It seems there have to be same wake_queue
after all.

Sorry,
Jarek P.
