From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV4] fib_trie: size and statistics
Date: Mon, 14 Jan 2008 23:28:16 -0800 (PST)
Message-ID: <20080114.232816.102558214.davem@davemloft.net>
References: <20080112.214417.154179770.davem@davemloft.net>
	<20080114125755.6157a3bf@deepthought>
	<478C58FD.9030407@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, robert.olsson@its.uu.se,
	netdev@vger.kernel.org, stephen.hemminger@vyatta.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46350
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751887AbYAOH2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 02:28:22 -0500
In-Reply-To: <478C58FD.9030407@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 15 Jan 2008 07:55:57 +0100

> Keeping a 'size' counter is not necessary, since trie_collect_stats() must go
> through all the tree and get this information for free.
> 
> This 'size' field only slows down inserts/deletes and dirty a cacheline that 
> readers will hit.

Good point, we can do this better in a follow-on patch.
