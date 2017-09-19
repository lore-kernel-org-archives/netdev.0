From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 0/4] test_rhashtable: don't allocate huge static
 array
Date: Tue, 19 Sep 2017 16:16:05 -0700 (PDT)
Message-ID: <20170919.161605.797741740663490176.davem@davemloft.net>
References: <20170919231214.2281-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50458 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751615AbdISXQG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:16:06 -0400
In-Reply-To: <20170919231214.2281-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed, 20 Sep 2017 01:12:10 +0200

> Add a test case for the rhlist interface.
> While at it, cleanup current rhashtable test a bit and add a check
> for max_size support.
> 
> No changes since v1, except in last patch.
> kbuild robot complained about large onstack allocation caused by
> struct rhltable when lockdep is enabled.

Looks good, series applied, thanks Florian.
