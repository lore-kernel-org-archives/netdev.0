From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] test_rhashtable: remove initdata annotation
Date: Thu, 21 Sep 2017 20:42:32 -0700 (PDT)
Message-ID: <20170921.204232.298006545281976204.davem@davemloft.net>
References: <20170921153608.8789-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41618 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751791AbdIVDmc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 23:42:32 -0400
In-Reply-To: <20170921153608.8789-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 21 Sep 2017 17:36:08 +0200

> kbuild test robot reported a section mismatch warning w. gcc 4.x:
> WARNING: lib/test_rhashtable.o(.text+0x139e):
> Section mismatch in reference from the function rhltable_insert.clone.3() to the variable .init.data:rhlt
> 
> so remove this annotation.
> 
> Fixes: cdd4de372ea06 ("test_rhashtable: add test case for rhl_table interface")
> Reported-by: kbuild test robot <lkp@intel.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
