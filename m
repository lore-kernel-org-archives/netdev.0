From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove redundant checking for sock timer state
Date: Fri, 01 Feb 2013 01:09:46 -0500 (EST)
Message-ID: <20130201.010946.584437309593473452.davem@davemloft.net>
References: <1359697980-28613-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384Ab3BAGJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 01:09:49 -0500
In-Reply-To: <1359697980-28613-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Fri, 1 Feb 2013 13:53:00 +0800

> It's unnecessary to check whether the sock timer to be stopped is
> pending or not in sk_stop_timer() as del_timer() will do the same
> thing later.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>

Did it even occur to you that when this code was written, this
"redundant" testing was also redundant, but that it might have been
done on purpose?

If you are going to change this code, you must understand why it was
written this way, because that is the only context in which you will
be able to justify removing the test.

Otherwise I'm ignoring this patch.
