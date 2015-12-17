From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: honor IFF_UP in tun_get_user()
Date: Thu, 17 Dec 2015 15:26:29 -0500 (EST)
Message-ID: <20151217.152629.1069959159227242440.davem@davemloft.net>
References: <1450285057.8474.80.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, curtw@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753476AbbLQU0b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 15:26:31 -0500
In-Reply-To: <1450285057.8474.80.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 Dec 2015 08:57:37 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> If a tun interface is turned down, we should not allow packet injection
> into the kernel.
> 
> Kernel does not send packets to the tun already.
> 
> TUNATTACHFILTER can not be used as only tun_net_xmit() is taking care
> of it.
> 
> Reported-by: Curt Wohlgemuth <curtw@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This looks fine, applied, thanks Eric.
