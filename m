From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipvlan: constify l3mdev_ops structure
Date: Sat, 15 Oct 2016 17:50:36 -0400 (EDT)
Message-ID: <20161015.175036.584156456725838147.davem@davemloft.net>
References: <1476546030-14324-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Julia.Lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36622 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750919AbcJOVui (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2016 17:50:38 -0400
In-Reply-To: <1476546030-14324-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sat, 15 Oct 2016 17:40:30 +0200

> This l3mdev_ops structure is only stored in the l3mdev_ops field of a
> net_device structure.  This field is declared const, so the l3mdev_ops
> structure can be declared as const also.  Additionally drop the
> __read_mostly annotation.
> 
> The semantic patch that adds const is as follows:
> (http://coccinelle.lip6.fr/)
 ...
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied, thanks.
