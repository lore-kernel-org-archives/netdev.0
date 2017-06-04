From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_tunnel: fix traffic class routing for tunnels
Date: Sun, 04 Jun 2017 19:50:18 -0400 (EDT)
Message-ID: <20170604.195018.518487162165124233.davem@davemloft.net>
References: <91e31c60-5994-6784-cfe8-6a18016c6524@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org, peter.a.dawson@boeing.com
To: mcbirnie.l@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751147AbdFDXuW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 19:50:22 -0400
In-Reply-To: <91e31c60-5994-6784-cfe8-6a18016c6524@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liam McBirnie <mcbirnie.l@gmail.com>
Date: Fri, 2 Jun 2017 15:12:26 +1000

> From: Liam McBirnie <mcbirnie.l@gmail.com>
> Date: Thu, 1 Jun 2017 15:36:01 +1000
> Subject: [PATCH net] ip6_tunnel: fix traffic class routing for tunnels
> 
> ip6_route_output() requires that the flowlabel contains the traffic
> class for policy routing.
> 
> Commit 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on
> encapsulated packets") removed the code which previously added the
> traffic class to the flowlabel.
> 
> The traffic class is added here because only route lookup needs the
> flowlabel to contain the traffic class.
> 
> Fixes: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on encapsulated packets")
> Signed-off-by: Liam McBirnie <liam.mcbirnie@boeing.com>

Applied and queued up for -stable, thanks.
