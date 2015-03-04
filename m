From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] team: don't traverse port list using rcu in
 team_set_mac_address
Date: Wed, 04 Mar 2015 16:02:00 -0500 (EST)
Message-ID: <20150304.160200.1361747224026478715.davem@davemloft.net>
References: <1425454591-7686-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49558 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbbCDVCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 16:02:02 -0500
In-Reply-To: <1425454591-7686-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  4 Mar 2015 08:36:31 +0100

> Currently the list is traversed using rcu variant. That is not correct
> since dev_set_mac_address can be called which eventually calls
> rtmsg_ifinfo_build_skb and there, skb allocation can sleep. So fix this
> by remove the rcu usage here.
> 
> Fixes: 3d249d4ca7 "net: introduce ethernet teaming device"
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied and queued up for -stable, thanks.
