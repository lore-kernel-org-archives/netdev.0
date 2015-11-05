From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: use sk_fullsock() in ipv4_conntrack_defrag()
Date: Thu, 05 Nov 2015 14:37:05 -0500 (EST)
Message-ID: <20151105.143705.1683546745658073293.davem@davemloft.net>
References: <1446752046.4184.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dvyukov@google.com, pablo@netfilter.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbbKEThH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 14:37:07 -0500
In-Reply-To: <1446752046.4184.49.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Nov 2015 11:34:06 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Before converting a 'socket pointer' into inet socket,
> use sk_fullsock() to detect timewait or request sockets.
> 
> Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
> Please David merge this directly into net tree, I am sure Pablo
> wont object for a fast track. Thanks !

Yep, applied, thanks Eric.
