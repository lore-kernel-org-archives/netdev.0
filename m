From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] sit: fix panic with route cache in ip tunnels
Date: Thu, 20 Feb 2014 13:14:39 -0500 (EST)
Message-ID: <20140220.131439.585115913443330990.davem@davemloft.net>
References: <5304DA44.2090305@6wind.com>
	<1392887971-10590-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, therbert@google.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754106AbaBTSOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 13:14:41 -0500
In-Reply-To: <1392887971-10590-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 20 Feb 2014 10:19:31 +0100

> Bug introduced by commit 7d442fab0a67 ("ipv4: Cache dst in tunnels").
> 
> Because sit code does not call ip_tunnel_init(), the dst_cache was not
> initialized.
> 
> CC: Tom Herbert <therbert@google.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied, thanks Nicolas.
