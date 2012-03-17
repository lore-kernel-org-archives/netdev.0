From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] isdn: Return -EINTR in gigaset_start() if locking
 attempts fails.
Date: Sat, 17 Mar 2012 13:58:54 -0700 (PDT)
Message-ID: <20120317.135854.570143927282385505.davem@davemloft.net>
References: <1331903413-11426-1-git-send-email-santoshprasadnayak@gmail.com>
	<20120316.231856.1071253468993560433.davem@davemloft.net>
	<CAOD=uF6JJiiGjQwybzwdU3Zw9pC8YbDPxm_Pg9E9WNAXbfTiUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hjlipp@web.de, tilman@imap.cc, isdn@linux-pingi.de,
	gigaset307x-common@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-media@vger.kernel.org, kernel-janitors@vger.kernel.org
To: santoshprasadnayak@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756039Ab2CQU7W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Mar 2012 16:59:22 -0400
In-Reply-To: <CAOD=uF6JJiiGjQwybzwdU3Zw9pC8YbDPxm_Pg9E9WNAXbfTiUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Date: Sat, 17 Mar 2012 21:26:14 +0530

> Caller is interpreting 0 in opposite way of normal sequence.
> Thats why I misunderstood it.

The simple fact is that you didn't even look at the code at the call
sites when you wrote this patch, and that's the first thing anyone is
going to do when reviewing it.

Therefore your laziness results in more useless work for other people.
I just wanted to point out how selfish and anti-social this kind of
behavior is.
