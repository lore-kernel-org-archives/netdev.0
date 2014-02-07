From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] bridge: fix netconsole setup over bridge
Date: Thu, 06 Feb 2014 22:28:43 -0800 (PST)
Message-ID: <20140206.222843.247213341900385510.davem@davemloft.net>
References: <1391727652-12520-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, makita.toshiaki@lab.ntt.co.jp,
	stephen@networkplumber.org, cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40349 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbaBGG2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Feb 2014 01:28:43 -0500
In-Reply-To: <1391727652-12520-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu,  6 Feb 2014 15:00:52 -0800

> From: Cong Wang <cwang@twopensource.com>
> 
> Commit 93d8bf9fb8f3 ("bridge: cleanup netpoll code") introduced
> a check in br_netpoll_enable(), but this check is incorrect for
> br_netpoll_setup(). This patch moves the code after the check
> into __br_netpoll_enable() and calls it in br_netpoll_setup().
> For br_add_if(), the check is still needed.
> 
> Fixes: 93d8bf9fb8f3 ("bridge: cleanup netpoll code")
> Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <cwang@twopensource.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable.
