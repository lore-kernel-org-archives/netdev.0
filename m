From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net-qdisc-hhf: Heavy-Hitter Filter (HHF) qdisc
Date: Thu, 19 Dec 2013 14:30:45 -0500 (EST)
Message-ID: <20131219.143045.472862795767521855.davem@davemloft.net>
References: <1386746796-490-1-git-send-email-vtlam@google.com>
	<1387096221-20112-1-git-send-email-vtlam@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nanditad@google.com, edumazet@google.com
To: vtlam@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754396Ab3LSTar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 14:30:47 -0500
In-Reply-To: <1387096221-20112-1-git-send-email-vtlam@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Terry Lam <vtlam@google.com>
Date: Sun, 15 Dec 2013 00:30:21 -0800

> This patch implements the first size-based qdisc that attempts to
> differentiate between small flows and heavy-hitters.  The goal is to
> catch the heavy-hitters and move them to a separate queue with less
> priority so that bulk traffic does not affect the latency of critical
> traffic.  Currently "less priority" means less weight (2:1 in
> particular) in a Weighted Deficit Round Robin (WDRR) scheduler.

Can someone please review this, thanks!
