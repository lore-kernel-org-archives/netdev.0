From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] spectrum: acl_tcam: Fix catchall prio value
Date: Tue, 07 Feb 2017 14:16:16 -0500 (EST)
Message-ID: <20170207.141616.1968546832439148215.davem@davemloft.net>
References: <1486484867-8058-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, dan.carpenter@oracle.com,
        David.Laight@ACULAB.COM
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55322 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755011AbdBGTQS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 14:16:18 -0500
In-Reply-To: <1486484867-8058-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  7 Feb 2017 17:27:47 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> This fixes an issue reported by smatch:
> mlxsw_sp_acl_tcam_chunk_create() warn: impossible condition '(priority == (-1)) => (0-u32max == u64max)'
> 
> Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
> Reported-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Fixes: 22a677661f56 ("mlxsw: spectrum: Introduce ACL core with simple TCAM implementation")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Acked-by: Ido Schimmel <idosch@mellanox.com>
> ---
> v1->v2:
> - using (~0u) as suggested by David Laight

Applied.
