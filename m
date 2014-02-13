From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] macvlan: unregister net device when
 netdev_upper_dev_link() fails
Date: Thu, 13 Feb 2014 17:13:10 -0500 (EST)
Message-ID: <20140213.171310.161519083049405534.davem@davemloft.net>
References: <1392162690-6647-1-git-send-email-xiyou.wangcong@gmail.com>
	<1392162690-6647-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, cwang@twopensource.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50598 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbaBMWNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:13:18 -0500
In-Reply-To: <1392162690-6647-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 11 Feb 2014 15:51:29 -0800

> From: Cong Wang <cwang@twopensource.com>
> 
> rtnl_newlink() doesn't unregister it for us on failure.
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Cong Wang <cwang@twopensource.com>

Applied.
