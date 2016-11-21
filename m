From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] bridge: add support for IGMPv3 and MLDv2
 querier
Date: Mon, 21 Nov 2016 13:17:15 -0500 (EST)
Message-ID: <20161121.131715.1012790937919983633.davem@davemloft.net>
References: <1479729805-23108-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        sashok@cumulusnetworks.com, stephen@networkplumber.org,
        liuhangbin@gmail.com
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55644 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752054AbcKUSRR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 13:17:17 -0500
In-Reply-To: <1479729805-23108-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Mon, 21 Nov 2016 13:03:23 +0100

> This patch-set adds support for IGMPv3 and MLDv2 querier in the bridge.
> Two new options which can be toggled via netlink and sysfs are added that
> control the version per-bridge:
>  multicast_igmp_version - default 2, can be set to 3
>  multicast_mld_version - default 1, can be set to 2 (this option is
>                          disabled if CONFIG_IPV6=n)
> 
> Note that the names do not include "querier", I think that these options
> can be re-used later as more IGMPv3 support is added to the bridge so we
> can avoid adding more options to switch between v2 and v3 behaviour.
> 
> The set uses the already existing br_ip{4,6}_multicast_alloc_query
> functions and adds the appropriate header based on the chosen version.
> 
> For the initial support I have removed the compatibility implementation
> (RFC3376 sec 7.3.1, 7.3.2; RFC3810 sec 8.3.1, 8.3.2), because there are
> some details that we need to sort out.

Series applied, thanks.
