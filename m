From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: Do not consider link state for nexthop
 validation
Date: Thu, 27 Oct 2016 16:34:11 -0400 (EDT)
Message-ID: <20161027.163411.2198499719090919446.davem@davemloft.net>
References: <1477337243-10650-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33910 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S942249AbcJ0UeN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 16:34:13 -0400
In-Reply-To: <1477337243-10650-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Mon, 24 Oct 2016 12:27:23 -0700

> Similar to IPv4, do not consider link state when validating next hops.
> 
> Currently, if the link is down default routes can fail to insert:
>  $ ip -6 ro add vrf blue default via 2100:2::64 dev eth2
>  RTNETLINK answers: No route to host
> 
> With this patch the command succeeds.
> 
> Fixes: 8c14586fc320 ("net: ipv6: Use passed in table for nexthop lookups")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied and queued up for -stable.
