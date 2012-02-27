From: David Miller <davem@davemloft.net>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Mon, 27 Feb 2012 14:39:30 -0500 (EST)
Message-ID: <20120227.143930.785331756803521221.davem@davemloft.net>
References: <20120222055139.GB8026@google.com>
	<1329896195.18384.83.camel@edumazet-laptop>
	<CADVnQyk+ujAXPh1=59TB-Pb6ZcQX8NWCN5pWoNvXXLBnr6qOhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738Ab2B0Tjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2012 14:39:33 -0500
In-Reply-To: <CADVnQyk+ujAXPh1=59TB-Pb6ZcQX8NWCN5pWoNvXXLBnr6qOhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Thu, 23 Feb 2012 13:39:00 -0500

> If we wanted a larger sample of truesize/len ratios, perhaps we'd want
> some sort of exponentially weighted moving average of skb->truesize
> and skb->len, or the ratio of the two. That could give us a larger
> sample even for well-behaved apps that keep their read queues short.
> But that is starting to seem like it's perhaps overkill.

I don't think it's overkill at all.

And I would do it per-device only on MSS or larger frames using
extremely coarse units to avoid flaps and encorage quick convergance.
