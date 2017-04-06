From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] nfp: fix potential use after free on xdp prog
Date: Wed, 05 Apr 2017 18:47:08 -0700 (PDT)
Message-ID: <20170405.184708.708302621362328912.davem@davemloft.net>
References: <20170404225655.31119-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kubakici@wp.pl, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49046 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756644AbdDFBrK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 21:47:10 -0400
In-Reply-To: <20170404225655.31119-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue,  4 Apr 2017 15:56:55 -0700

> We should unregister the net_device first, before we give back
> our reference on xdp_prog.  Otherwise xdp_prog may be freed
> before .ndo_stop() disabled the datapath.  Found by code inspection.
> 
> Fixes: ecd63a0217d5 ("nfp: add XDP support in the driver")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>

Applied, thanks.

> ---
> Just a heads up - this will cause a merge conflict since nn->netdev
> member got moved to nn->dp.netdev in net-next.

Ok, thanks for the heads up.
