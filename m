From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dev: deinit list in unregister_netdevice_many
Date: Wed, 27 Feb 2013 02:21:25 -0500 (EST)
Message-ID: <20130227.022125.374228548587492555.davem@davemloft.net>
References: <1361948391-4906-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: gaofeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab3B0HV3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 02:21:29 -0500
In-Reply-To: <1361948391-4906-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


mroute_clean_tables() uses the list after unregister_netdevice_many().

Can you please just stop tinkering in this area?  You are making many
careless errors.

Thanks.
