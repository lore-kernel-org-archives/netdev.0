From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] net: Verify permission to dest_net in newlink
Date: Sat, 28 Feb 2015 15:15:15 -0500 (EST)
Message-ID: <20150228.151515.662671773116842835.davem@davemloft.net>
References: <87wq34okb9.fsf@x220.int.ebiederm.org>
	<54EF3338.8000409@6wind.com>
	<87egpcmi3v.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eugene.yakubovich@coreos.com, netdev@vger.kernel.org,
	nicolas.dichtel@6wind.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbbB1UPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2015 15:15:18 -0500
In-Reply-To: <87egpcmi3v.fsf_-_@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 26 Feb 2015 16:19:00 -0600

> When applicable verify that the caller has permision to create a
> network device in another network namespace.  This check is already
> present when moving a network device between network namespaces in
> setlink so all that is needed is to duplicate that check in newlink.
> 
> This change almost backports cleanly, but there are context conflicts
> as the code that follows was added in v4.0-rc1
> 
> Fixes: b51642f6d77b131dc85d1d71029c3cbb5b07c262 net: Enable a userns root rtnl calls that are safe for unprivilged users
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>

Applied.
