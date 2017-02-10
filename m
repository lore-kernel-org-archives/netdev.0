From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] spectrum: flower: Treat ETH_P_ALL as a
 special case and translate for HW
Date: Fri, 10 Feb 2017 14:42:15 -0500 (EST)
Message-ID: <20170210.144215.10575178963659286.davem@davemloft.net>
References: <1486647723-14776-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47236 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932197AbdBJTu6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 14:50:58 -0500
In-Reply-To: <1486647723-14776-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  9 Feb 2017 14:42:03 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> HW does not understand ETH_P_ALL. So treat this special case differently
> and translate to 0/0 key/mask. That will allow HW to match all ethertypes.
> 
> Fixes: 7aa0f5aa9030 ("mlxsw: spectrum: Implement TC flower offload")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Applied.
