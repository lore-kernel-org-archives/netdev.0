From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] 6lowpan: code updates
Date: Wed, 16 May 2012 15:28:01 -0400 (EDT)
Message-ID: <20120516.152801.915753046212672140.davem@davemloft.net>
References: <1337153248-5779-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52638 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932429Ab2EPT2F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 15:28:05 -0400
In-Reply-To: <1337153248-5779-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Wed, 16 May 2012 11:27:26 +0400

>   6lowpan: rework data fetching from skb

This is not what we told you to do.

We told you that IF you were going to emit a warning message
for the pskb_may_pull() failure condition, you should use
WARN_ON_ONCE() so that it doesn't potentially flood the
logs.

But you must always, in every case, handle the error in some
reasonable way, not just when WARN_ON_ONCE() does that initial
one-and-only trigger.
