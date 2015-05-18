From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] netns: make nsid_lock per net
Date: Sun, 17 May 2015 23:41:30 -0400 (EDT)
Message-ID: <20150517.234130.220724394890542785.davem@davemloft.net>
References: <1431726452-13111-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51406 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbbERDlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 23:41:31 -0400
In-Reply-To: <1431726452-13111-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 15 May 2015 14:47:32 -0700

> The spinlock is used to protect netns_ids which is per net,
> so there is no need to use a global spinlock.
> 
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
