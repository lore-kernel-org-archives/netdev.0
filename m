From: David Miller <davem@davemloft.net>
Subject: Re: Change in alloc_skb() behavior in 3.2+ kernels?
Date: Wed, 06 Jun 2012 12:02:47 -0700 (PDT)
Message-ID: <20120606.120247.1618312724057709285.davem@davemloft.net>
References: <jqo7op$t6f$1@dough.gmane.org>
	<1339008142.26966.40.camel@edumazet-glaptop>
	<jqo9a6$ah6$1@dough.gmane.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: grant.b.edwards@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab2FFTCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 15:02:48 -0400
In-Reply-To: <jqo9a6$ah6$1@dough.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Edwards <grant.b.edwards@gmail.com>
Date: Wed, 6 Jun 2012 18:59:19 +0000 (UTC)

> At the time it was written (probably 10+ years ago) it was relying on
> the documented API for alloc_skb() that stated alloc_skb() either
> returned an sk_buff of the requested size or it failed.

It was never a formal API that we would only allocate 'size'
amount of tailroom.
