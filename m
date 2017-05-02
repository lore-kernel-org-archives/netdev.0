From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next repost] net: sched: add helpers to handle
 extended actions
Date: Tue, 02 May 2017 15:34:15 -0400 (EDT)
Message-ID: <20170502.153415.1593517080151959057.davem@davemloft.net>
References: <1493712720-1501-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53360 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751243AbdEBTeQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 15:34:16 -0400
In-Reply-To: <1493712720-1501-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  2 May 2017 10:12:00 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Jump is now the only one using value action opcode. This is going to
> change soon. So introduce helpers to work with this. Convert TC_ACT_JUMP.
> 
> This also fixes the TC_ACT_JUMP check, which is incorrectly done as a
> bit check, not a value check.
> 
> Fixes: e0ee84ded796 ("net sched actions: Complete the JUMPX opcode")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> Dave, I'm sending this for -net-next although I know it is closed. But
> the mentioned commit is not yet in -net. Feel free to take this either
> to -net-next or -net, whatever suits you better. Thanks.

Applied to net-next, thanks Jiri.
