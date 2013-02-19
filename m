From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] net: fix a build failure when !CONFIG_PROC_FS
Date: Tue, 19 Feb 2013 13:19:46 -0500 (EST)
Message-ID: <20130219.131946.567072598115741930.davem@davemloft.net>
References: <1361278025-22864-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gaofeng@cn.fujitsu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933365Ab3BSSTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 13:19:48 -0500
In-Reply-To: <1361278025-22864-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 19 Feb 2013 20:47:05 +0800

> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> When !CONFIG_PROC_FS dev_mcast_init() is not defined,
> actually we can just merge dev_mcast_init() into
> dev_proc_init().
> 
> Reported-by: Gao feng <gaofeng@cn.fujitsu.com>
> Cc: Gao feng <gaofeng@cn.fujitsu.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

I definitely prefer this version of this fix, applied, thanks.
