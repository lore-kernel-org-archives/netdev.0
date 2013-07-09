From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net/fs: change busy poll time accounting
Date: Tue, 09 Jul 2013 12:33:30 -0700 (PDT)
Message-ID: <20130709.123330.253388383875496669.davem@davemloft.net>
References: <20130709100921.21602.46444.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	dwmw2@infradead.org, eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58513 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396Ab3GITdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 15:33:33 -0400
In-Reply-To: <20130709100921.21602.46444.stgit@ladj378.jer.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Tue, 09 Jul 2013 13:09:21 +0300

> Sorry, I forgot to commit before sending, so I sent the wrong version.
> The previous version gets a warning in busy_loop_timeout().
> 
> Suggested by Linus:
> Changed time accounting for busy-poll:
> - Make it microsecond based.
> - Use unsigned longs.
> - Revert back to use time_after instead of time_in_range.
> Reorder poll/select busy loop conditions:
> - Clear busy_flag after one time we can't busy-poll.
> - Only init busy_end if we actually are going to busy-poll.
> Added one more missing need_resched() test.
> 
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>

Ok, looks good, applied.

Thanks!
