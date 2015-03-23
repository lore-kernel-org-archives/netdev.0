From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] fib_trie: Fix regression in handling of
 inflate/halve failure
Date: Mon, 23 Mar 2015 16:59:27 -0400 (EDT)
Message-ID: <20150323.165927.1681969466296183568.davem@davemloft.net>
References: <20150323185142.1079.79248.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58258 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbbCWU73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 16:59:29 -0400
In-Reply-To: <20150323185142.1079.79248.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>
Date: Mon, 23 Mar 2015 11:51:53 -0700

> When I updated the code to address a possible null pointer dereference in
> resize I ended up reverting an exception handling fix for the suffix length
> in the event that inflate or halve failed.  This change is meant to correct
> that by reverting the earlier fix and instead simply getting the parent
> again after inflate has been completed to avoid the possible null pointer
> issue.
> 
> Fixes: ddb4b9a13 ("fib_trie: Address possible NULL pointer dereference in resize")
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>

Applied, thanks.
