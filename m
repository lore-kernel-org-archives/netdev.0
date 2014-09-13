From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: exit early in addrconf_notify() if IPv6
 is disabled
Date: Sat, 13 Sep 2014 16:39:57 -0400 (EDT)
Message-ID: <20140913.163957.221290010232987682.davem@davemloft.net>
References: <1410473236-3346-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbaIMUj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 16:39:58 -0400
In-Reply-To: <1410473236-3346-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Thu, 11 Sep 2014 15:07:16 -0700

> If IPv6 is explicitly disabled before the interface comes up,
> it makes no sense to continue when it comes up, even just
> print a message.
> 
> (I am not sure about other cases though, so I prefer not to touch)
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
