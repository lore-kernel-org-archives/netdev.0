From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ip6_tunnel: Allow rcv/xmit even if remote
 address is a local address
Date: Wed, 25 Oct 2017 10:34:25 +0900 (KST)
Message-ID: <20171025.103425.239621897812285829.davem@davemloft.net>
References: <20171020212515.4678-1-shmulik@nsof.io>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulik.ladkani@gmail.com
To: shmulik@nsof.io
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41852 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751870AbdJYBea (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 21:34:30 -0400
In-Reply-To: <20171020212515.4678-1-shmulik@nsof.io>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik@nsof.io>
Date: Sat, 21 Oct 2017 00:25:15 +0300

> From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> 
> Currently, ip6_tnl_xmit_ctl drops tunneled packets if the remote
> address (outer v6 destination) is one of host's locally configured
> addresses.
> Same applies to ip6_tnl_rcv_ctl: it drops packets if the remote address
> (outer v6 source) is a local address.
> 
> This prevents using ipxip6 (and ip6_gre) tunnels whose local/remote
> endpoints are on same host; OTOH v4 tunnels (ipip or gre) allow such
> configurations.
> 
> An example where this proves useful is a system where entities are
> identified by their unique v6 addresses, and use tunnels to encapsulate
> traffic between them. The limitation prevents placing several entities
> on same host.
> 
> Introduce IP6_TNL_F_ALLOW_LOCAL_REMOTE which allows to bypass this
> restriction.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Given this wasn't allowed for so long, making it configurable makes
sense.

Applied, thanks.
