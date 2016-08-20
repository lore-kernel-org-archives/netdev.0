From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum_buffers: Fix pool value handling
 in mlxsw_sp_sb_tc_pool_bind_set
Date: Fri, 19 Aug 2016 18:04:25 -0700 (PDT)
Message-ID: <20160819.180425.2257746495527073067.davem@davemloft.net>
References: <1471610628-4287-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56238 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754781AbcHTBE0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 21:04:26 -0400
In-Reply-To: <1471610628-4287-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 19 Aug 2016 14:43:48 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Pool index has to be converted by get_pool helper to work correctly for
> egress pool. In mlxsw the egress pool index starts from 0.
> 
> Fixes: 0f433fa0ecc ("mlxsw: spectrum_buffers: Implement shared buffer configuration")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
