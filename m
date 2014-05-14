From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv4: make ip_local_reserved_ports per netns
Date: Wed, 14 May 2014 15:32:02 -0400 (EDT)
Message-ID: <20140514.153202.632022868786147086.davem@davemloft.net>
References: <1399935893-15874-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53647 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbaENTcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:32:03 -0400
In-Reply-To: <1399935893-15874-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 12 May 2014 16:04:53 -0700

> ip_local_port_range is already per netns, so should ip_local_reserved_ports
> be. And since it is none by default we don't actually need it when we don't
> enable CONFIG_SYSCTL.
> 
> By the way, rename inet_is_reserved_local_port() to inet_is_local_reserved_port()
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

This is fine, applied to net-next, thanks.
