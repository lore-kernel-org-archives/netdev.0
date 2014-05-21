From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: fix an oops in tcindex filter
Date: Wed, 21 May 2014 16:51:08 -0400 (EDT)
Message-ID: <20140521.165108.1433532620660314918.davem@davemloft.net>
References: <1400526949-1344-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com, kelly@xilka.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55864 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752866AbaEUUvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 16:51:10 -0400
In-Reply-To: <1400526949-1344-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 19 May 2014 12:15:49 -0700

> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> Kelly reported the following crash:
 ...
> This is because we memcpy struct tcindex_filter_result which contains
> struct tcf_exts, obviously struct list_head can not be simply copied.
> This is a regression introduced by commit 33be627159913b094bb578
> (net_sched: act: use standard struct list_head).
> 
> It's not very easy to fix it as the code is a mess:
 ...
> Fixes: commit 33be627159913b0 (net_sched: act: use standard struct list_head)
> Reported-by: Kelly Anderson <kelly@xilka.com>
> Tested-by: Kelly Anderson <kelly@xilka.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thank you.
