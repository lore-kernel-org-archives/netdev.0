From: David Miller <davem@davemloft.net>
Subject: Re: [V2 PATCH] sctp: Restore 'resent' bit to avoid retransmitted
 chunks for RTT measurements
Date: Thu, 28 Nov 2013 18:30:24 -0500 (EST)
Message-ID: <20131128.183024.1122040393172123504.davem@davemloft.net>
References: <1385350017-11324-1-git-send-email-xufeng.zhang@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: xufeng.zhang@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47397 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329Ab3K1XaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:30:25 -0500
In-Reply-To: <1385350017-11324-1-git-send-email-xufeng.zhang@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xufeng Zhang <xufeng.zhang@windriver.com>
Date: Mon, 25 Nov 2013 11:26:57 +0800

> Currently retransmitted DATA chunks could also be used for
> RTT measurements since there are no flag to identify whether
> the transmitted DATA chunk is a new one or a retransmitted one.
> This problem is introduced by commit ae19c5486 ("sctp: remove
> 'resent' bit from the chunk") which inappropriately removed the
> 'resent' bit completely, instead of doing this, we should set
> the resent bit only for the retransmitted DATA chunks.
> 
> Signed-off-by: Xufeng Zhang <xufeng.zhang@windriver.com>
> ---
> v1->v2:
> Rmoved initialization for resent bit.
> Combined two if clause

Applied, thanks.
