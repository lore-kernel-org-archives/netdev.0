From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] rps: selective flow shedding during
 softnet overflow
Date: Tue, 23 Apr 2013 18:33:14 -0400 (EDT)
Message-ID: <20130423.183314.1228017537381500979.davem@davemloft.net>
References: <CA+FuTSfPjrzVqKj-jrzivM_mBP47Dtkuj2P+bJ3VwWTscoT=yA@mail.gmail.com>
	<1366749094-5982-1-git-send-email-willemb@google.com>
	<20130423142333.15479dfa@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: willemb@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755793Ab3DWWdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 18:33:16 -0400
In-Reply-To: <20130423142333.15479dfa@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 23 Apr 2013 14:23:33 -0700

> What about just having a smarter ingress qdisc?

Ingress qdiscs go through a single lock, and that is not likely to
change any time soon, nor do I find it reasonable to be required to
use ingress qdiscs to handle this problem.

I find Willem's changes extremely reasonable, and a good improvement
we should integrate now rather than pretending ingress qdiscs are an
acceptable alternative.  They aren't.
