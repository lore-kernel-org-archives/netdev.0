From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] qfq: don't leak skb if kzalloc fails
Date: Wed, 08 Jun 2016 22:42:00 -0700 (PDT)
Message-ID: <20160608.224200.1252447699887026317.davem@davemloft.net>
References: <1465420981-13638-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41922 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932448AbcFIFmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 01:42:02 -0400
In-Reply-To: <1465420981-13638-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  8 Jun 2016 23:23:01 +0200

> When we need to create a new aggregate to enqueue the skb we call kzalloc.
> If that fails we returned ENOBUFS without freeing the skb.
> 
> Spotted during code review.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
