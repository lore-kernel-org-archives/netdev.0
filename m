From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net: use for_each_netdev_safe() in
 rtnl_group_changelink()
Date: Tue, 24 Mar 2015 13:02:54 -0400 (EDT)
Message-ID: <20150324.130254.1666495511890518435.davem@davemloft.net>
References: <1427153469-32542-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37612 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932202AbbCXRC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 13:02:57 -0400
In-Reply-To: <1427153469-32542-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 23 Mar 2015 16:31:09 -0700

> In case we move the whole dev group to another netns,
> we should call for_each_netdev_safe(), otherwise we get
> a soft lockup:
 ...
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied and queued up for -stable, thanks.
