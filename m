From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] ipv6: fix missing in6_ifa_put in addrconf
Date: Tue, 16 Nov 2010 09:35:22 -0800 (PST)
Message-ID: <20101116.093522.112573959.davem@davemloft.net>
References: <20101116062921.31164.70903.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43477
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755973Ab0KPRe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 12:34:57 -0500
In-Reply-To: <20101116062921.31164.70903.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Mon, 15 Nov 2010 22:29:21 -0800

> Fix ref count bug introduced by
> 
> commit 2de795707294972f6c34bae9de713e502c431296
> Author: Lorenzo Colitti <lorenzo@google.com>
> Date:   Wed Oct 27 18:16:49 2010 +0000
> 
> ipv6: addrconf: don't remove address state on ifdown if the address
> is being kept
> 
> 
> Fix logic so that addrconf_ifdown() decrements the inet6_ifaddr
> refcnt correctly with in6_ifa_put().
> 
> Reported-by: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks a lot.
