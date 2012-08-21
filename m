From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: fix ip header ident selection in __ip_make_skb()
Date: Tue, 21 Aug 2012 14:51:27 -0700 (PDT)
Message-ID: <20120821.145127.2073110448958014270.davem@davemloft.net>
References: <1345483605.5158.345.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	casteyde.christian@free.fr
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45240 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758482Ab2HUVv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 17:51:28 -0400
In-Reply-To: <1345483605.5158.345.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Aug 2012 19:26:45 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Christian Casteyde reported a kmemcheck 32-bit read from uninitialized
> memory in __ip_select_ident().
> 
> It turns out that __ip_make_skb() called ip_select_ident() before
> properly initializing iph->daddr.
> 
> This is a bug uncovered by commit 1d861aa4b3fb (inet: Minimize use of
> cached route inetpeer.)
> 
> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=46131
> 
> Reported-by: Christian Casteyde <casteyde.christian@free.fr>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Eric.
