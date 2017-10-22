From: David Miller <davem@davemloft.net>
Subject: Re: [patch net 0/2] mlxsw: spectrum: Configure TTL of "inherit"
 for offloaded tunnels
Date: Sun, 22 Oct 2017 02:19:50 +0100 (WEST)
Message-ID: <20171022.021950.94283084189078828.davem@davemloft.net>
References: <20171020071616.1498-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57024 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932271AbdJVBTz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 21:19:55 -0400
In-Reply-To: <20171020071616.1498-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 20 Oct 2017 09:16:14 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Petr says:
> 
> Currently mlxsw only offloads tunnels that are configured with TTL of "inherit"
> (which is the default). However, Spectrum defaults to 255 and the driver
> neglects to change the configuration. Thus the tunnel packets from offloaded
> tunnels always have TTL of 255, even though tunnels with explicit TTL of 255 are
> never actually offloaded.
> 
> To fix this, introduce support for TIGCR, the register that keeps the related
> bits of global tunnel configuration, and use it on first offload to properly
> configure inheritance of TTL of tunnel packets from overlay packets.

Series applied.
