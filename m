From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: statically link
 register_inet6addr_notifier()
Date: Sun, 14 Apr 2013 15:24:33 -0400 (EDT)
Message-ID: <20130414.152433.1785408480242968385.davem@davemloft.net>
References: <1365952723-23295-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tomas.melin@iki.fi, yoshfuji@linux-ipv6.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753474Ab3DNTYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Apr 2013 15:24:35 -0400
In-Reply-To: <1365952723-23295-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Sun, 14 Apr 2013 23:18:43 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> Tomas reported the following build error:
> 
> net/built-in.o: In function `ieee80211_unregister_hw':
> (.text+0x10f0e1): undefined reference to `unregister_inet6addr_notifier'
> net/built-in.o: In function `ieee80211_register_hw':
> (.text+0x10f610): undefined reference to `register_inet6addr_notifier'
> make: *** [vmlinux] Error 1
> 
> when built IPv6 as a module.
> 
> So we have to statically link these symbols.
> 
> Reported-by: Tomas Melin <tomas.melin@iki.fi>
> Cc: Tomas Melin <tomas.melin@iki.fi>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: YOSHIFUJI Hidaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Cong Wang <amwang@redhat.com>

This bug exists in 'net' so that's where I'm applying this.
