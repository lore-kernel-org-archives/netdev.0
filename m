From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] test_rhashtable: add test case for rhl
 table
Date: Tue, 19 Sep 2017 14:03:27 -0700 (PDT)
Message-ID: <20170919.140327.234018891173976958.davem@davemloft.net>
References: <20170918210711.10202-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45058 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751431AbdISVD2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 17:03:28 -0400
In-Reply-To: <20170918210711.10202-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 18 Sep 2017 23:07:07 +0200

> Add a test case for the rhlist interface.
> 
> While at it, cleanup current rhashtable test a bit and add a check
> for max_size support.

The kbuild test robot complained about a very large on-stack allocation
added by these changes, please address that.

Thanks.
