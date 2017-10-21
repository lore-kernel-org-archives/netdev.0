From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: ipv4_default_advmss() should use route
 mtu
Date: Sat, 21 Oct 2017 01:55:27 +0100 (WEST)
Message-ID: <20171021.015527.168790442446504300.davem@davemloft.net>
References: <1508371323.31614.156.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45942 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753008AbdJUAza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 20:55:30 -0400
In-Reply-To: <1508371323.31614.156.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 18 Oct 2017 17:02:03 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> ipv4_default_advmss() incorrectly uses the device MTU instead
> of the route provided one. IPv6 has the proper behavior,
> lets harmonize the two protocols.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
