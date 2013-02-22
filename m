From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix error handling in icmp_protocol.
Date: Fri, 22 Feb 2013 15:15:05 -0500 (EST)
Message-ID: <20130222.151505.2238431448054721865.davem@davemloft.net>
References: <1361521124-1135-1-git-send-email-lw@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lw@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757031Ab3BVUPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 15:15:08 -0500
In-Reply-To: <1361521124-1135-1-git-send-email-lw@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Wei <lw@cn.fujitsu.com>
Date: Fri, 22 Feb 2013 16:18:44 +0800

> Now we handle icmp errors in each transport protocol's err_handler,
> for icmp protocols, that is ping_err. Since this handler only care
> of those icmp errors triggered by echo request, errors triggered
> by echo reply(which sent by kernel) are sliently ignored.
> 
> So wrap ping_err() with icmp_err() to deal with those icmp errors.
> 
> Signed-off-by: Li Wei <lw@cn.fujitsu.com>

Applied and queue up for -stable, thanks.
