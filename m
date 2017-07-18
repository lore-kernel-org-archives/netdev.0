From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/22] mlxsw: Preparations for IPv6 UC router
Date: Tue, 18 Jul 2017 11:59:30 -0700 (PDT)
Message-ID: <20170718.115930.1637290327157187407.davem@davemloft.net>
References: <20170718081030.2781-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54500 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751443AbdGRS7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 14:59:31 -0400
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 18 Jul 2017 10:10:08 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Ido says:
> 
> The purpose of this set is to prepare the driver for the introduction of
> IPv6 FIB offload. It's mainly composed of small and non-functional
> changes, that either add the IPv6 equivalent of existing IPv4 code or
> aimed at making the introduction of IPv6-specific code easier.
> 
> The first five patches enable IPv6 forwarding in the device and allow us
> to configure router interfaces (RIFs) based on inet6addr notifications.
> 
> The next six patches add support for programming IPv6 neighbours into
> the device's table as well as dumping their activity and updating the
> kernel accordingly.
> 
> The last 11 patches extend current infrastructure to allow us to program
> IPv6 routes, set catch-all IPv6 trap in case of abort and make the code
> more receptive towards up-coming changes.

A lot of small, easy to understand, changes.  I like.

Series applied, thanks.
