From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 05/14] net: macb: Use net_device_stats from
 struct net_device
Date: Fri, 07 Apr 2017 07:08:20 -0700 (PDT)
Message-ID: <20170407.070820.1152842497622881545.davem@davemloft.net>
References: <20170407081739.5243-6-tklauser@distanz.ch>
        <06673f1b-60d3-9749-c3cb-f35d9579a98f@microchip.com>
        <20170407085709.GA16513@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@microchip.com, netdev@vger.kernel.org
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54176 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755430AbdDGOIW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 10:08:22 -0400
In-Reply-To: <20170407085709.GA16513@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri, 7 Apr 2017 10:57:09 +0200

> With a quick git/google search I couldn't really find any information on
> why net_device_stats was deemed legacy and whether it is still allowed
> to be used. It seems the comment saying so was introduced in
> 536721b1cb3f ("net: kernel-doc compliant documentation for net_device")
> but neither the log message specifies nor the mailing list thread
> provide any further information.

The 64-bit link stats overflow less frequently and are the native format
passed to modern applications fetching stats via netlink.
