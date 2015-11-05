From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] selinux: fix random read in
 selinux_ip_postroute_compat()
Date: Thu, 05 Nov 2015 16:46:13 -0500 (EST)
Message-ID: <20151105.164613.618044250901993825.davem@davemloft.net>
References: <CACT4Y+ZVnfoqeJZ5cOKu70d3N9LuPMeotarKGBx-EHwYrOe-Eg@mail.gmail.com>
	<1446752806.4184.50.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446759564.4184.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dvyukov@google.com, netdev@vger.kernel.org, paul@paul-moore.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39748 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbbKEVqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 16:46:15 -0500
In-Reply-To: <1446759564.4184.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Nov 2015 13:39:24 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit e446f9dfe17b ("net: synack packets can be attached to request
> sockets"), I missed one remaining case of invalid skb->sk->sk_security
> access.
> 
> Dmitry Vyukov got a KASan report pointing to it.
> 
> Add selinux_skb_sk() helper that is responsible to get back to the
> listener if skb is attached to a request socket, instead of
> duplicating the logic.
> 
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Paul Moore <paul@paul-moore.com>

Looks good, applied, thanks Eric!
