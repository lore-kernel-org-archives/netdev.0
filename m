From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next 0/3] use netdev_is_rx_handler_busy() in few known
 cases
Date: Fri, 20 Jan 2017 12:22:47 -0500 (EST)
Message-ID: <20170120.122247.579482338385386692.davem@davemloft.net>
References: <20170118230245.20674-1-mahesh@bandewar.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, maheshb@google.com
To: mahesh@bandewar.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34102 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752126AbdATRas (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:30:48 -0500
In-Reply-To: <20170118230245.20674-1-mahesh@bandewar.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <mahesh@bandewar.net>
Date: Wed, 18 Jan 2017 15:02:45 -0800

> netdev_rx_handler_register() was recently split into two parts - (a) check
> if the handler is used, (b) register the new handler, parts. This is 
> helpful in scenarios like bonding where at the time of registration there
> is too much state to unwind and it should check if the device is free
> before building that state. IPvlan and macvlan drivers don't have this
> issue however it can make use of the same check instead of using a device
> specific check.

Looks good, series applied, thanks.
