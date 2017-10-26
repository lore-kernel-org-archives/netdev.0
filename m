From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/4] net: sched: move the can_offload check
 from binding phase to rule insertion phase
Date: Thu, 26 Oct 2017 10:01:31 +0900 (KST)
Message-ID: <20171026.100131.1516530767097739079.davem@davemloft.net>
References: <20171025143500.28973-1-jiri@resnulli.us>
        <20171025143500.28973-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55878 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751868AbdJZBBk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 21:01:40 -0400
In-Reply-To: <20171025143500.28973-3-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 25 Oct 2017 16:34:58 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> This restores the original behaviour before the block callbacks were
> introduced. Allow the drivers to do binding of block always, no matter
> if the NETIF_F_HW_TC feature is on or off. Move the check to the block
> callback which is called for rule insertion.
> 
> Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

I agree with Jakub's feedback, if every callback has to make this check
why not just do it in the core where the callback is invoked?
