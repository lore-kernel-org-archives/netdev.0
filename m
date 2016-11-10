From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnl: reset calcit fptr in rtnl_unregister()
Date: Wed, 09 Nov 2016 20:18:33 -0500 (EST)
Message-ID: <20161109.201833.426669913716180780.davem@davemloft.net>
References: <1478557339-16039-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
        gregory.v.rose@intel.com
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46450 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754654AbcKJBSk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 20:18:40 -0500
In-Reply-To: <1478557339-16039-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Mon,  7 Nov 2016 23:22:19 +0100

> To avoid having dangling function pointers left behind, reset calcit in
> rtnl_unregister(), too.
> 
> This is no issue so far, as only the rtnl core registers a netlink
> handler with a calcit hook which won't be unregistered, but may become
> one if new code makes use of the calcit hook.
> 
> Fixes: c7ac8679bec9 ("rtnetlink: Compute and store minimum ifinfo...")
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Applied, thanks.
