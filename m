From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: connect() from bound sockets can be
 faster
Date: Wed, 27 May 2015 14:31:43 -0400 (EDT)
Message-ID: <20150527.143143.1055130037582665499.davem@davemloft.net>
References: <1432743498.4060.399.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432744246.4060.406.camel@edumazet-glaptop2.roam.corp.google.com>
	<1432748762.4060.414.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cdleonard@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751584AbbE0Sbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 14:31:46 -0400
In-Reply-To: <1432748762.4060.414.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 May 2015 10:46:02 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> __inet_hash_connect() does not use its third argument (port_offset)
> if socket was already bound to a source port.
> 
> No need to perform useless but expensive md5 computations.
> 
> Reported-by: Crestez Dan Leonard <cdleonard@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks great, applied, thanks Eric!
