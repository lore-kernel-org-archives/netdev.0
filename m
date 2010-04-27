From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: sk_add_backlog() take rmem_alloc
 into account
Date: Tue, 27 Apr 2010 15:11:03 -0700 (PDT)
Message-ID: <20100427.151103.146348463.davem@davemloft.net>
References: <1272389872.2295.405.camel@edumazet-laptop>
	<1272399662.2343.12.camel@edumazet-laptop>
	<20100427.144307.22037530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bmb@athenacr.com, therbert@google.com, netdev@vger.kernel.org,
	rick.jones2@hp.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46628
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754928Ab0D0WK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 18:10:57 -0400
In-Reply-To: <20100427.144307.22037530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 27 Apr 2010 14:43:07 -0700 (PDT)

> This looks great, applied, thanks Eric!

I have to fix this one up, for example SCTP stopped building because it
still refers to the ->limit member you removed.
