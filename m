From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fq_codel: should use qdisc backlog as
 threshold
Date: Wed, 16 May 2012 15:30:37 -0400 (EDT)
Message-ID: <20120516.153037.524884393884635968.davem@davemloft.net>
References: <1337179149.8512.1208.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nichols@pollere.com,
	dave.taht@bufferbloat.net, van@pollere.net,
	codel@lists.bufferbloat.net, bloat@lists.bufferbloat.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52687 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755770Ab2EPTbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 15:31:45 -0400
In-Reply-To: <1337179149.8512.1208.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 16 May 2012 16:39:09 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> codel_should_drop() logic allows a packet being not dropped if queue
> size is under max packet size.
> 
> In fq_codel, we have two possible backlogs : The qdisc global one, and
> the flow local one.
> 
> The meaningful one for codel_should_drop() should be the global backlog,
> not the per flow one, so that thin flows can have a non zero drop/mark
> probability.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
