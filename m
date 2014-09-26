From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net : optimize skb_release_data()
Date: Fri, 26 Sep 2014 16:54:15 -0400 (EDT)
Message-ID: <20140926.165415.1181309765564566739.davem@davemloft.net>
References: <1411522770.15395.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51320 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756124AbaIZUyR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 16:54:17 -0400
In-Reply-To: <1411522770.15395.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 23 Sep 2014 18:39:30 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Cache skb_shinfo(skb) in a variable to avoid computing it multiple
> times.
> 
> Reorganize the tests to remove one indentation level.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
