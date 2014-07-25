From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/9] inet: frag: don't account number of
 fragment queues
Date: Thu, 24 Jul 2014 23:15:43 -0700 (PDT)
Message-ID: <20140724.231543.185389386835334722.davem@davemloft.net>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
	<1406213437-6155-6-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	alex.aring@gmail.com, eric.dumazet@gmail.com
To: nikolay@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751298AbaGYGPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2014 02:15:46 -0400
In-Reply-To: <1406213437-6155-6-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@redhat.com>
Date: Thu, 24 Jul 2014 16:50:33 +0200

> From: Florian Westphal <fw@strlen.de>
> 
> The 'nqueues' counter is protected by the lru list lock,
> once thats removed this needs to be converted to atomic
> counter.  Given this isn't used for anything except for
> reporting it to userspace via /proc, just remove it.
> 
> We still report the memory currently used by fragment
> reassembly queues.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

It's a user visible value, you can't just change it's semantics.
