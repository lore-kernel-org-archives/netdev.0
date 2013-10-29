From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] tipc: message reassembly using fragment
 chain
Date: Mon, 28 Oct 2013 23:49:53 -0400 (EDT)
Message-ID: <20131028.234953.1884858499661587979.davem@davemloft.net>
References: <20131028.010737.400887499395331496.davem@davemloft.net>
	<526E3B49.9030506@donjonn.com>
	<526F15E8.9020009@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maloy@donjonn.com, jon.maloy@ericsson.com,
	paul.gortmaker@windriver.com, erik.hugne@ericsson.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40219 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756896Ab3J2Dtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 23:49:55 -0400
In-Reply-To: <526F15E8.9020009@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Tue, 29 Oct 2013 09:56:56 +0800

> Therefore, the best method is to divide tipc_recv_msg() into several
> smaller functions to simplify the current implementation. But it's not
> an easy job. Actually I ever tried to do it, but I gave up lastly
> because I did not find one perfect solution about how to divide it.

But you're going to have to find a way, this indent level is out of
control.
