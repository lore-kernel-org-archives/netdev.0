From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] isdn: Use ktime_t instead of 'struct timeval'
Date: Sun, 31 May 2015 21:38:00 -0700 (PDT)
Message-ID: <20150531.213800.1614880603855736021.davem@davemloft.net>
References: <20150531071937.GA3980@tinar>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
	y2038@lists.linaro.org
To: ruchandani.tina@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45307 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755804AbbFAEiB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 00:38:01 -0400
In-Reply-To: <20150531071937.GA3980@tinar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tina Ruchandani <ruchandani.tina@gmail.com>
Date: Sun, 31 May 2015 12:49:37 +0530

> 'struct timeval' uses 32-bit representation for seconds which will
> overflow in year 2038 and beyond. mISDN/clock.c needs to compute and
> store elapsed time in intervals of 125 microseconds. This patch replaces
> the usage of 'struct timeval' with 64-bit ktime_t which is y2038 safe.
> The patch also replaces do_gettimeofday (wall-clock time) with ktime_get
> (monotonic time) since we only care about elapsed time here.
> 
> Signed-off-by: Tina Ruchandani <ruchandani.tina@gmail.com>
> Suggested-by: Arnd Bergmnann <arnd@arndb.de>

This doesn't apply cleanly to net-next.
