From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Missing @ before descriptions cause make xmldocs
 warning
Date: Thu, 09 Oct 2014 18:57:26 -0400 (EDT)
Message-ID: <20141009.185726.2200139354739768161.davem@davemloft.net>
References: <1412827088-30718-1-git-send-email-standby24x7@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	edumazet@google.com
To: standby24x7@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751065AbaJIW52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 18:57:28 -0400
In-Reply-To: <1412827088-30718-1-git-send-email-standby24x7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masanari Iida <standby24x7@gmail.com>
Date: Thu,  9 Oct 2014 12:58:08 +0900

> This patch fix following warning.
> Warning(.//net/core/skbuff.c:4142): No description found for parameter 'header_len'
> Warning(.//net/core/skbuff.c:4142): No description found for parameter 'data_len'
> Warning(.//net/core/skbuff.c:4142): No description found for parameter 'max_page_order'
> Warning(.//net/core/skbuff.c:4142): No description found for parameter 'errcode'
> Warning(.//net/core/skbuff.c:4142): No description found for parameter 'gfp_mask'
> 
> Acutually the descriptions exist, but missing "@" in front.
> 
> This problem start to happen when following commit was merged
> into Linus's tree during 3.18-rc1 merge period.
> commit 2e4e44107176d552f8bb1bb76053e850e3809841
> net: add alloc_skb_with_frags() helper
> 
> Signed-off-by: Masanari Iida <standby24x7@gmail.com>

Applied, thank you.
