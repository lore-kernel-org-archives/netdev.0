From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] etherdevice: introduce eth_broadcast_addr
Date: Tue, 10 Jul 2012 17:41:42 -0700 (PDT)
Message-ID: <20120710.174142.995966539991957646.davem@davemloft.net>
References: <20120708.235808.1602900783296556684.davem@davemloft.net>
	<1341937124.4475.27.camel@jlt3.sipsolutions.net>
	<CAP=VYLqNyAF1gSsKTd3YojeJXK_-pEzXAKyVQbQfwhtwOyMmwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42329 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754745Ab2GKAln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2012 20:41:43 -0400
In-Reply-To: <CAP=VYLqNyAF1gSsKTd3YojeJXK_-pEzXAKyVQbQfwhtwOyMmwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Tue, 10 Jul 2012 20:09:44 -0400

> On Tue, Jul 10, 2012 at 12:18 PM, Johannes Berg
> <johannes@sipsolutions.net> wrote:
>> From: Johannes Berg <johannes.berg@intel.com>
>>
>> A lot of code has either the memset or an inefficient copy
>> from a static array that contains the all-ones broadcast
> 
> Shouldn't we see all that "lot of code" here in this same
> commit, now using this new shortcut?

I disagree and I intend to apply Johannes's patch as-is to net-next.
