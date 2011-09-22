From: David Miller <davem@davemloft.net>
Subject: Re: routing table error in 2.6.39 ..
Date: Thu, 22 Sep 2011 14:21:10 -0400 (EDT)
Message-ID: <20110922.142110.1470776655731016807.davem@davemloft.net>
References: <CAGZFCEHtyE1MutMmhKefFm9Xx5rri1j7DR7L=cFU3KUg7ejs4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: user-mode-linux-user@lists.sourceforge.net,
	user-mode-linux-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: ratheesh.ksz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36734 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160Ab1IVSVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 14:21:21 -0400
In-Reply-To: <CAGZFCEHtyE1MutMmhKefFm9Xx5rri1j7DR7L=cFU3KUg7ejs4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Date: Thu, 22 Sep 2011 21:25:47 +0530

> in 2.6.38 routing  table is  correct. But in 2.6.39 default gw appears
> on top of the routing table. same problem persist in 3.0.0 also.

You cannot depend upon the order in which routing table entries
are listed by the kernel.

The table internally is correct, and lookups will match using the
proper longest-matching-prefix algorithm.
