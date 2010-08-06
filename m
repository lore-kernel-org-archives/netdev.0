From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: convert to rcu_dereference_index_check()
Date: Fri, 06 Aug 2010 14:49:01 -0700 (PDT)
Message-ID: <20100806.144901.184847372.davem@davemloft.net>
References: <20100806212607.GA9410@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, arnd@arndb.de
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43410
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762102Ab0HFVsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 17:48:42 -0400
In-Reply-To: <20100806212607.GA9410@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Fri, 6 Aug 2010 14:26:07 -0700

> At long last, the following is the final patch blocking acceptance
> of Arnd's sparse annotations for RCU.  It was itself blocked behind
> the definition of rcu_dereference_index_check(), which made it to
> mainline only just today.
> 
> Would you be willing to ack this patch so that I can push it to -tip,
> along with Arnd's work and a bunch of other stuff?
 ...
>     net: convert to rcu_dereference_index_check()
>     
>     The task_cls_classid() function applies rcu_dereference() to integers,
>     which does not work with the shiny new sparse-based checking in
>     rcu_dereference().  This commit therefore moves to the new RCU API
>     rcu_dereference_index_check().
>     
>     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>     Reviewed-by: Josh Triplett <josh@joshtriplett.org>

You should of course wait for Herbert's ACK too, but for
the record:

Acked-by: David S. Miller <davem@davemloft.net>

:-)
