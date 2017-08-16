From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] ipv6: fib: Provide offload indication using
 nexthop flags
Date: Tue, 15 Aug 2017 17:05:17 -0700 (PDT)
Message-ID: <20170815.170517.2085855853566792385.davem@davemloft.net>
References: <20170815070949.1363-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        dsahern@gmail.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, hannes@stressinduktion.org,
        yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751095AbdHPAFS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:05:18 -0400
In-Reply-To: <20170815070949.1363-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 15 Aug 2017 09:09:49 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> IPv6 routes currently lack nexthop flags as in IPv4. This has several
> implications.
> 
> In the forwarding path, it requires us to check the carrier state of the
> nexthop device and potentially ignore a linkdown route, instead of
> checking for RTNH_F_LINKDOWN.
> 
> It also requires capable drivers to use the user facing IPv6-specific
> route flags to provide offload indication, instead of using the nexthop
> flags as in IPv4.
> 
> Add nexthop flags to IPv6 routes in the 40 bytes hole and use it to
> provide offload indication instead of the RTF_OFFLOAD flag, which is
> removed while it's still not part of any official kernel release.
> 
> In the near future we would like to use the field for the
> RTNH_F_{LINKDOWN,DEAD} flags, but this change is more involved and might
> not be ready in time for the current cycle.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
