From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netlink: add missing length check of rtnl msg
Date: Mon, 25 Mar 2013 13:54:38 -0400 (EDT)
Message-ID: <20130325.135438.105490515572492532.davem@davemloft.net>
References: <1364232143-16754-1-git-send-email-honkiko@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org, tgraf@suug.ch
To: honkiko@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54488 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab3CYRyk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 13:54:40 -0400
In-Reply-To: <1364232143-16754-1-git-send-email-honkiko@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <honkiko@gmail.com>
Date: Tue, 26 Mar 2013 01:22:23 +0800

> When the legacy array rtm_min still exists, the length check within these 
> functions is covered by rtm_min[RTM_NEWTFILTER], rtm_min[RTM_NEWQDISC] 
> and rtm_min[RTM_NEWTCLASS].
> 
> But after Thomas Graf removed rtm_min several days ago, these checks are 
> missing. 
> 
> Other doit functions should be OK.
> 
> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>

This looks good, Thomas please review.
