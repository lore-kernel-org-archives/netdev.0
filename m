From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next repost 0/8] mlxsw: Add IPv6 host dpipe table
Date: Thu, 31 Aug 2017 14:43:20 -0700 (PDT)
Message-ID: <20170831.144320.554040883431439478.davem@davemloft.net>
References: <20170831155919.1366-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59060 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751009AbdHaVnV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 17:43:21 -0400
In-Reply-To: <20170831155919.1366-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 31 Aug 2017 17:59:11 +0200

> This patchset adds IPv6 host dpipe table support. This will provide the
> ability to observe the hardware offloaded IPv6 neighbors.

Series applied, thanks.

I noticed while reviewing this we are pretty much split on how
to access neigh->primary_key.

Half the code goes "(type *) n->primary_key" and the other half
(mostly in ipv6) goes "(type *) &n->primary_key"

I know both forms are basically equivalent, but consistency
matters :-)
