From: David Miller <davem@davemloft.net>
Subject: Re: [patch 12/28] fib_trie: cleanup
Date: Fri, 10 Aug 2007 15:22:30 -0700 (PDT)
Message-ID: <20070810.152230.77404660.davem@davemloft.net>
References: <200708102111.l7ALBuvR009406@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	paulmck@linux.vnet.ibm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54370
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754562AbXHJWW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 18:22:29 -0400
In-Reply-To: <200708102111.l7ALBuvR009406@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: akpm@linux-foundation.org
Date: Fri, 10 Aug 2007 14:11:56 -0700

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> Try this out:
>      * replace macro's with inlines
>      * get rid of places doing multiple evaluations of NODE_PARENT
> 
> [akpm@linux-foundation.org: rcu_dereference wants an lval]
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Applied to net-2.6.24, thanks!
