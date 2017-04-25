From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: fix source routing
Date: Tue, 25 Apr 2017 13:59:50 -0400 (EDT)
Message-ID: <20170425.135950.1293244907738125591.davem@davemloft.net>
References: <1d451d4d6c04c259280dee65caeabf3e00e0eb94.1493128459.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
        david.lebrun@uclouvain.be
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43182 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951605AbdDYR7w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 13:59:52 -0400
In-Reply-To: <1d451d4d6c04c259280dee65caeabf3e00e0eb94.1493128459.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 25 Apr 2017 15:56:50 +0200

> Commit a149e7c7ce81 ("ipv6: sr: add support for SRH injection through
> setsockopt") introduced handling of IPV6_SRCRT_TYPE_4, but at the same
> time restricted it to only IPV6_SRCRT_TYPE_0 and
> IPV6_SRCRT_TYPE_4. Previously, ipv6_push_exthdr() and fl6_update_dst()
> would also handle other values (ie STRICT and TYPE_2).
> 
> Restore previous source routing behavior, by handling IPV6_SRCRT_STRICT
> and IPV6_SRCRT_TYPE_2 the same way as IPV6_SRCRT_TYPE_0 in
> ipv6_push_exthdr() and fl6_update_dst().
> 
> Fixes: a149e7c7ce81 ("ipv6: sr: add support for SRH injection through setsockopt")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Reviewed-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied, thanks.
