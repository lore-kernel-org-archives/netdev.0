From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] netlink: have length check of rtnl msg
 before deref
Date: Tue, 26 Mar 2013 12:36:17 -0400 (EDT)
Message-ID: <20130326.123617.948609374458177904.davem@davemloft.net>
References: <1364232143-16754-1-git-send-email-honkiko@gmail.com>
	<1364268993-19947-1-git-send-email-honkiko@gmail.com>
	<20130326085937.GE27194@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: honkiko@gmail.com, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965643Ab3CZQgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Mar 2013 12:36:19 -0400
In-Reply-To: <20130326085937.GE27194@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue, 26 Mar 2013 08:59:37 +0000

> On 03/26/13 at 11:36am, Hong Zhiguo wrote:
>> When the legacy array rtm_min still exists, the length check within
>> these functions is covered by rtm_min[RTM_NEWTFILTER],
>> rtm_min[RTM_NEWQDISC] and rtm_min[RTM_NEWTCLASS].
>> 
>> But after Thomas Graf removed rtm_min several days ago, these checks
>> are missing. Other doit functions should be OK.
>> 
>> Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks.
