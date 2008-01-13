From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/9] statistics improvements
Date: Sat, 12 Jan 2008 21:44:17 -0800 (PST)
Message-ID: <20080112.214417.154179770.davem@davemloft.net>
References: <20080112064646.282104074@linux-foundation.org>
	<20080112.205520.55747078.davem@davemloft.net>
	<4789A29C.6080000@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56007
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750816AbYAMFoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2008 00:44:18 -0500
In-Reply-To: <4789A29C.6080000@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sat, 12 Jan 2008 21:33:16 -0800

> The size field is added to /proc/net/fib_triestat that was the point.

Not from what I can see.

davem@sunset:~/src/GIT/net-2.6.25$ git grep -e "->size" net/ipv4/fib_trie.c
net/ipv4/fib_trie.c:	t->size++;
net/ipv4/fib_trie.c:	t->size--;
davem@sunset:~/src/GIT/net-2.6.25$ git grep -e "\.size" net/ipv4/fib_trie.c
davem@sunset:~/src/GIT/net-2.6.25$ 

Nothing uses the field, it is merely incremented and decremented.

trie_show_stats() and trie_show_usage() do not access this field.
