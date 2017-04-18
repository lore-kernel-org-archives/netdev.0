From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] rhashtable: remove insecure_elasticity
Date: Tue, 18 Apr 2017 13:49:38 -0400 (EDT)
Message-ID: <20170418.134938.272786427332860211.davem@davemloft.net>
References: <20170416005509.31784-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42564 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753042AbdDRRtk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 13:49:40 -0400
In-Reply-To: <20170416005509.31784-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun, 16 Apr 2017 02:55:09 +0200

> commit 83e7e4ce9e93c3 ("mac80211: Use rhltable instead of rhashtable")
> removed the last user that made use of 'insecure_elasticity' parameter,
> i.e. the default of 16 is used everywhere.
> 
> Replace it with a constant.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Yeah if it's not used, we can kill it.  If someone needs it again it is
trivial to add it back if necessary.

Applied, thanks Florian.
