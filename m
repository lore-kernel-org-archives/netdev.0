From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: propagate tc filter chain index down the
 ndo_setup_tc call
Date: Thu, 08 Jun 2017 09:56:39 -0400 (EDT)
Message-ID: <20170608.095639.1657737507053098910.davem@davemloft.net>
References: <20170606150016.2419-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        dsa@cumulusnetworks.com, edumazet@google.com, daniel@iogearbox.net,
        alexander.h.duyck@intel.com, simon.horman@netronome.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56132 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752377AbdFHN4r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 09:56:47 -0400
In-Reply-To: <20170606150016.2419-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  6 Jun 2017 17:00:16 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> We need to push the chain index down to the drivers, so they have the
> information to which chain the rule belongs. For now, no driver supports
> multichain offload, so only chain 0 is supported. This is needed to
> prevent chain squashes during offload for now. Later this will be used
> to implement multichain offload.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
