From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 0/2] ipv4: Fix memory leaks and reference issues in
 fib
Date: Wed, 16 Nov 2016 13:25:10 -0500 (EST)
Message-ID: <20161116.132510.2011910965305303771.davem@davemloft.net>
References: <20161115104306.13711.67911.stgit@ahduyck-blue-test.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45920 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752985AbcKPSZM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 13:25:12 -0500
In-Reply-To: <20161115104306.13711.67911.stgit@ahduyck-blue-test.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 15 Nov 2016 05:46:01 -0500

> This series fixes one major issue and one minor issue in the fib tables.
> 
> The major issue is that we had lost the functionality that was flushing the
> local table entries from main after we had unmerged the two tries.  In
> order to regain the functionality I have performed a partial revert and
> then moved the functionality for flushing the external entries from main
> into fib_unmerge.
> 
> The minor issue was a memory leak that could occur in the event that we
> weren't able to add an alias to the local trie resulting in the fib alias
> being leaked.

Series applied and queued up for -stable, thanks Alexander.
