From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum: Avoid possible NULL pointer
 dereference
Date: Thu, 18 May 2017 11:27:55 -0400 (EDT)
Message-ID: <20170518.112755.691557446541704509.davem@davemloft.net>
References: <20170518110352.14807-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44382 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932872AbdERP15 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:27:57 -0400
In-Reply-To: <20170518110352.14807-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 18 May 2017 13:03:52 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> In case we got an FDB notification for a port that doesn't exist we
> execute an FDB entry delete to prevent it from re-appearing the next
> time we poll for notifications.
> 
> If the operation failed we would trigger a NULL pointer dereference as
> 'mlxsw_sp_port' is NULL.
> 
> Fix it by reporting the error using the underlying bus device instead.
> 
> Fixes: 12f1501e7511 ("mlxsw: spectrum: remove FDB entry in case we get unknown object notification")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thank you.
