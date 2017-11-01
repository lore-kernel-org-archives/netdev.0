From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: i2c: Fix buffer increment counter for write
 transaction
Date: Wed, 01 Nov 2017 20:41:23 +0900 (KST)
Message-ID: <20171101.204123.1453756255961804863.davem@davemloft.net>
References: <20171101111042.8040-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vadimp@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52246 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753858AbdKALla (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 07:41:30 -0400
In-Reply-To: <20171101111042.8040-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed,  1 Nov 2017 12:10:42 +0100

> From: Vadim Pasternak <vadimp@mellanox.com>
> 
> It fixes a problem for the last chunk where 'chunk_size' is smaller than
> MLXSW_I2C_BLK_MAX and data is copied to the wrong offset, overriding
> previous data.
> 
> Fixes: 6882b0aee180 ("mlxsw: Introduce support for I2C bus")
> Signed-off-by: Vadim Pasternak <vadimp@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
