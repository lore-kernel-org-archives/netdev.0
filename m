From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/2] mlxsw: Fixes in GRE offloading
Date: Mon, 02 Oct 2017 11:19:45 -0700 (PDT)
Message-ID: <20171002.111945.1212607979984142796.davem@davemloft.net>
References: <20171002101457.1462-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46794 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751120AbdJBSTq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 14:19:46 -0400
In-Reply-To: <20171002101457.1462-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Mon,  2 Oct 2017 12:14:55 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Petr says:
> 
> This patchset fixes a couple unrelated problems in offloading IP-in-IP tunnels
> in mlxsw driver.
> 
> - The first patch fixes a potential reference-counting problem that might lead
>   to a kernel crash.
> 
> - The second patch associates IPIP next hops with their loopback RIFs. Besides
>   being the right thing to do, it also fixes a problem where offloaded IPv6
>   routes that forward to IP-in-IP netdevices were not flagged as such.

Series applied.
