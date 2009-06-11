From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [net-next PATCH 3/3] qlge: Increase default TX/RX ring size to
	1024.
Date: Thu, 11 Jun 2009 16:21:59 -0700
Message-ID: <20090611232159.GA13392@linux-ox1b.qlogic.org>
References: <1244684975-10211-1-git-send-email-ron.mercer@qlogic.com> <1244684975-10211-3-git-send-email-ron.mercer@qlogic.com> <20090611.022713.35602614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:51429 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733AbZFKX3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 19:29:22 -0400
Content-Disposition: inline
In-Reply-To: <20090611.022713.35602614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is huge.  Even other aggressive NICs such as BNX2X only use 256
> ring entries per TX queue.
> 
> There is a point where increasing definitely hurts, because you're
> increasing the resident set size of the cpu, as more and more SKBs are
> effectively "in flight" at a given time and only due to the amount
> you're allowing to get queued up into the chip.
> 
> And with multiqueue, per-queue TX queue sizes should matter less at
> least to some extent.
> 
> Are you sure that jacking the value up this high has no negative side
> effects for various workloads?

Just drop this patch for now.  I looked at our spreadsheet and ran the
tests again and we see a (marginal) throughput increase that leveled off
at TXQ length of 1024.  In light of yours and Stephens comments I prefer
to revisit this issue.

