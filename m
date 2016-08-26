From: David Miller <davem@davemloft.net>
Subject: Re: [patch net v2] team: loadbalance: push lacpdus to exact
 delivery
Date: Fri, 26 Aug 2016 13:13:54 -0700 (PDT)
Message-ID: <20160826.131354.1276719561146610708.davem@davemloft.net>
References: <1472142652-15004-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60286 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbcHZUN6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 16:13:58 -0400
In-Reply-To: <1472142652-15004-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 25 Aug 2016 18:30:52 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> When team is in bridge and LACP is utilized, LACPDU packets are pushed
> to userspace using raw socket and there they are processed. However,
> since 8626c56c8279b, LACPDU skbs are dropped by bridge rx_handler so
> they never reach packet handlers in rx path. Fix this by explicity treat
> LACPDUs to be pushed to exact delivery in team rx_handler.
> 
> Reported-by: Ido Schimmel <idosch@mellanox.com>
> Fixes: 8626c56c8279b ("bridge: fix potential use-after-free when hook returns QUEUE or STOLEN verdict")
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks Jiri.
