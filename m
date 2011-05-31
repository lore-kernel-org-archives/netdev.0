From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: stop pending timers and purge queues when peer
 restart asoc
Date: Tue, 31 May 2011 15:29:36 -0700 (PDT)
Message-ID: <20110531.152936.59320562.davem@davemloft.net>
References: <4DE36218.2090400@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41897 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932780Ab1EaW3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 18:29:43 -0400
In-Reply-To: <4DE36218.2090400@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Mon, 30 May 2011 17:23:36 +0800

> If the peer restart the asoc, we should not only fail any unsent/unacked
> data, but also stop the T3-rtx, SACK, T4-rto timers, and teardown ASCONF
> queues.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied, thanks.
