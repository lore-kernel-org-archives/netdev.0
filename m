From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net: use for_each_netdev_safe() in
 rtnl_group_changelink()
Date: Tue, 24 Mar 2015 13:03:16 -0400 (EDT)
Message-ID: <20150324.130316.1992586825650098426.davem@davemloft.net>
References: <1427153469-32542-1-git-send-email-xiyou.wangcong@gmail.com>
	<1427157352.25985.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37620 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964778AbbCXRDR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 13:03:17 -0400
In-Reply-To: <1427157352.25985.86.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 23 Mar 2015 17:35:52 -0700

> It seems this bug was added in commit e7ed828f10bd8, right ?
> 
> Fixes: e7ed828f10bd8 ("netlink: support setting devgroup parameters")

I added this to the commit message, thanks.
