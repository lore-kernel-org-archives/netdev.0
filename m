From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: fix l2tp_eth module loading
Date: Sun, 01 Oct 2017 22:35:42 -0700 (PDT)
Message-ID: <20171001.223542.893634246736740504.davem@davemloft.net>
References: <a7d351fd5948fc69ef17da3c170cd7c152f899c4.1506606179.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, tparkin@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60486 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdJBFfm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 01:35:42 -0400
In-Reply-To: <a7d351fd5948fc69ef17da3c170cd7c152f899c4.1506606179.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Thu, 28 Sep 2017 15:44:38 +0200

> The l2tp_eth module crashes if its netlink callbacks are run when the
> pernet data aren't initialised.
> 
> We should normally register_pernet_device() before the genl callbacks.
> However, the pernet data only maintain a list of l2tpeth interfaces,
> and this list is never used. So let's just drop pernet handling
> instead.
> 
> Fixes: d9e31d17ceba ("l2tp: Add L2TP ethernet pseudowire support")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks.
