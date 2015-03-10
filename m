From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] fib_trie: Correctly handle case of key == 0
 in leaf_walk_rcu
Date: Tue, 10 Mar 2015 16:14:26 -0400 (EDT)
Message-ID: <20150310.161426.2237948745314134712.davem@davemloft.net>
References: <20150310170746.GA1743@kria>
	<20150310182512.1320.1169.stgit@ahduyck-vm-fedora20>
	<20150310184839.GC1743@kria>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59847 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbCJUO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 16:14:28 -0400
In-Reply-To: <20150310184839.GC1743@kria>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 10 Mar 2015 19:48:39 +0100

> 2015-03-10, 11:25:41 -0700, Alexander Duyck wrote:
>> In the case of a trie that had no tnodes with a key of 0 the initial
>> look-up would fail resulting in an out-of-bounds cindex on the first tnode.
>> This resulted in an entire trie being skipped.
>> 
>> In order resolve this I have updated the cindex logic in the initial
>> look-up so that if the key is zero we will always traverse the child zero
>> path.
>> 
>> Fixes: 8be33e95 ("fib_trie: Fib walk rcu should take a tnode and key instead of a trie and a leaf")
>> Reported-by: Sabrina Dubroca <sd@queasysnail.net>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
>> ---
> 
> Tested-by: Sabrina Dubroca <sd@queasysnail.net>

Applied, thanks everyone.
