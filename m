From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] busy_poll: cleanup do-nothing placeholders
Date: Sun, 04 Aug 2013 19:41:39 -0700 (PDT)
Message-ID: <20130804.194139.1872286759580440582.davem@davemloft.net>
References: <20130804095548.30006.8133.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eliezer@tamir.org.il
To: eliezer.tamir@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442Ab3HEClk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Aug 2013 22:41:40 -0400
In-Reply-To: <20130804095548.30006.8133.stgit@ladj378.jer.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Date: Sun, 04 Aug 2013 12:55:48 +0300

> When renaming ll_poll to busy poll, I introduced a typo
> in the name of the do-nothing placeholder for sk_busy_loop
> and called it sk_busy_poll.
> This broke compile when busy poll was not configured.
> Cong Wang submitted a patch to fixed that.
> This patch removes the now redundant, misspelled placeholder.
> 
> Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>

Applied, thanks.
