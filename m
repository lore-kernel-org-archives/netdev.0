From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/7] More sane neigh infrastructure
Date: Mon, 25 Jul 2011 14:10:41 -0700 (PDT)
Message-ID: <20110725.141041.1092565620930748250.davem@davemloft.net>
References: <20110725.030109.1723861338142084129.davem@davemloft.net>
	<CAG4TOxOv1WsgfRXxrBWWq-+9ee3apEE0B_Onn+JB=tEEuOhhxg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752422Ab1GYVKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 17:10:46 -0400
In-Reply-To: <CAG4TOxOv1WsgfRXxrBWWq-+9ee3apEE0B_Onn+JB=tEEuOhhxg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@kernel.org>
Date: Mon, 25 Jul 2011 09:34:16 -0700

> So I don't think we can use custom neigh_ops with a new solict method
> the way clip does -- we actually want to let the normal stack do ARP
> or ND, but then extend the process by another message/response step.
> I'm sure this is possible within your scheme but I'm not sure I
> understand what the "right" way is.

So call the normal ARP neigh solicit stuff in your neigh ops, and do
your local stuff there as well.

See if you can make it work.

