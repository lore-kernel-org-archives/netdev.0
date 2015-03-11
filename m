From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fib_trie: Fix uninitialized variable warning
Date: Wed, 11 Mar 2015 17:34:02 -0400 (EDT)
Message-ID: <20150311.173402.2009482302052640139.davem@davemloft.net>
References: <20150311210211.7975.98821.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52210 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378AbbCKVfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 17:35:33 -0400
In-Reply-To: <20150311210211.7975.98821.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Wed, 11 Mar 2015 14:02:16 -0700

> The 0-day kernel test infrastructure reported a use of uninitialized
> variable warning for local_table due to the fact that the local and main
> allocations had been swapped from the original setup.  This change corrects
> that by making it so that we free the main table if the local table
> allocation fails.
> 
> Fixes: 0ddcf43d5 ("ipv4: FIB Local/MAIN table collapse")
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied, thanks Alex.
