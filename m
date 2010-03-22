From: David Miller <davem@davemloft.net>
Subject: Re: RCU problems in fib_table_insert
Date: Sun, 21 Mar 2010 18:01:40 -0700 (PDT)
Message-ID: <20100321.180140.45887114.davem@davemloft.net>
References: <20100321202525.GA966@basil.fritz.box>
	<20100321213703.GD2517@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50358
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753201Ab0CVBBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:01:18 -0400
In-Reply-To: <20100321213703.GD2517@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Date: Sun, 21 Mar 2010 14:37:03 -0700

> net: suppress lockdep-RCU false positive in FIB trie.
> 
> Allow fib_find_node() to be called either under rcu_read_lock()
> protection or with RTNL held.
> 
> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

Thanks guys, I applied this copy and added Eric's signoff
since the two patches were essentially identical :-)
