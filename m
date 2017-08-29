From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] addrlabel: don't use rtnl locking
Date: Tue, 29 Aug 2017 09:42:07 -0700 (PDT)
Message-ID: <20170829.094207.140341127832354750.davem@davemloft.net>
References: <20170829112942.4791-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34930 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751306AbdH2QmI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 12:42:08 -0400
In-Reply-To: <20170829112942.4791-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 29 Aug 2017 13:29:40 +0200

> addrlabel doesn't appear to require rtnl lock as the addrlabel
> table uses a spinlock to serialize add/delete operations.
> 
> Also, entries are reference counted so it should be safe
> to call the rtnl ops without the rtnl mutex.

Series applied.
