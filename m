From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Add module reference to FIB notifiers
Date: Fri, 01 Sep 2017 20:34:30 -0700 (PDT)
Message-ID: <20170901.203430.1204195231321352853.davem@davemloft.net>
References: <20170901091517.31271-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, dsahern@gmail.com,
        mlxsw@mellanox.com
To: idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58004 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdIBDeb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 23:34:31 -0400
In-Reply-To: <20170901091517.31271-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>
Date: Fri,  1 Sep 2017 12:15:17 +0300

> When a listener registers to the FIB notification chain it receives a
> dump of the FIB entries and rules from existing address families by
> invoking their dump operations.
> 
> While we call into these modules we need to make sure they aren't
> removed. Do that by increasing their reference count before invoking
> their dump operations and decrease it afterwards.
> 
> Fixes: 04b1d4e50e82 ("net: core: Make the FIB notification chain generic")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reviewed-by: Jiri Pirko <jiri@mellanox.com>

Oops, yes, you'll need to do this.

Applied, thanks.
