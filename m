From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum_flower: Remove bogus warns in
 mlxsw_sp_flower_destroy
Date: Wed, 08 Mar 2017 23:17:12 -0800 (PST)
Message-ID: <20170308.231712.2243269503106885571.davem@davemloft.net>
References: <1488831729-4438-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, ivecera@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60486 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750793AbdCIHRc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 02:17:32 -0500
In-Reply-To: <1488831729-4438-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon,  6 Mar 2017 21:22:09 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> This warnings may be hit even in case they should not - in case user
> puts a TC-flower rule which failed to be offloaded. So just remove them.
> 
> Reported-by: Petr Machata <petrm@mellanox.com>
> Reported-by: Ido Schimmel <idosch@mellanox.com>
> Fixes: commit 7aa0f5aa9030 ("mlxsw: spectrum: Implement TC flower offload")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Acked-by: Ido Schimmel <idosch@mellanox.com>

Applied.
