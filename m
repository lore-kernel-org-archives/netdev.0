From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: acl: Fix mlxsw_afa_block_commit error
 path
Date: Wed, 08 Feb 2017 15:14:08 -0500 (EST)
Message-ID: <20170208.151408.2292767944646557589.davem@davemloft.net>
References: <1486546756-1950-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, dan.carpenter@oracle.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58052 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751501AbdBHUOj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 15:14:39 -0500
In-Reply-To: <1486546756-1950-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  8 Feb 2017 10:39:16 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> No rollback is needed since the chain is in consistent state and
> mlxsw_afa_block_destroy() will take care of putting it away. So remove
> the one we have now which is wrong. Also move the set of 'finished' flag
> to the beginning of the function, because the block is certainly unusable
> for future action addition no matter if the function succeeds or not.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Fixes: 4cda7d8d7098 ("mlxsw: core: Introduce flexible actions support")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Acked-by: Ido Schimmel <idosch@mellanox.com>

Applied.
