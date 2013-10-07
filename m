From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix ineffective source address selection
Date: Mon, 07 Oct 2013 15:27:25 -0400 (EDT)
Message-ID: <20131007.152725.1114664126409429664.davem@davemloft.net>
References: <245895a0777442b56ecea1453be041aa1b31c5a2.1380898983.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756321Ab3JGT11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 15:27:27 -0400
In-Reply-To: <245895a0777442b56ecea1453be041aa1b31c5a2.1380898983.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri,  4 Oct 2013 17:04:48 +0200

> When sending out multicast messages, the source address in inet->mc_addr is
> ignored and rewritten by an autoselected one. This is caused by a typo in
> commit 813b3b5db831 ("ipv4: Use caller's on-stack flowi as-is in output
> route lookups").
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

My bad :-)  Applied and queued up for -stable, thanks!
