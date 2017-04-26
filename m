From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rhashtable: remove insecure_max_entries param
Date: Wed, 26 Apr 2017 14:39:41 -0400 (EDT)
Message-ID: <20170426.143941.969875526076911806.davem@davemloft.net>
References: <20170425094134.21885-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59214 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965161AbdDZSjm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:39:42 -0400
In-Reply-To: <20170425094134.21885-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 25 Apr 2017 11:41:34 +0200

> no users in the tree, insecure_max_entries is always set to
> ht->p.max_size * 2 in rhtashtable_init().
> 
> Replace only spot that uses it with a ht->p.max_size check.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
