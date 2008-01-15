From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [IPV4] fib_trie: size and statistics
Date: Mon, 14 Jan 2008 23:12:06 -0800 (PST)
Message-ID: <20080114.231206.217868623.davem@davemloft.net>
References: <4789A29C.6080000@linux-foundation.org>
	<20080112.214417.154179770.davem@davemloft.net>
	<20080114125755.6157a3bf@deepthought>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	stephen.hemminger@vyatta.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40550
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751954AbYAOHMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 02:12:12 -0500
In-Reply-To: <20080114125755.6157a3bf@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 14 Jan 2008 12:57:55 -0800

> Show number of entries in trie, the size field was being set but never used,
> but it only counted leaves, not all entries. Refactor the two cases in
> fib_triestat_seq_show into a single routine.
> 
> Note: the stat structure was being malloc'd but the stack usage isn't so
> high (288 bytes) that it is worth the additional complexity.
> 
> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>

Applied, thanks.
