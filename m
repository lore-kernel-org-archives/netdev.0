From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: netlink: account for
 IFLA_BRPORT_{B,M}CAST_FLOOD size and policy
Date: Fri, 05 May 2017 11:22:44 -0400 (EDT)
Message-ID: <20170505.112244.1416767855257763172.davem@davemloft.net>
References: <20170505143653.8486-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
        netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        mmanning@brocade.com
To: tklauser@distanz.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751437AbdEEPYB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 11:24:01 -0400
In-Reply-To: <20170505143653.8486-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Klauser <tklauser@distanz.ch>
Date: Fri,  5 May 2017 16:36:53 +0200

> The attribute sizes for IFLA_BRPORT_MCAST_FLOOD and
> IFLA_BRPORT_BCAST_FLOOD weren't accounted for in br_port_info_size()
> when they were added. Do so now and also add the corresponding policy
> entries:
> 
> Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Cc: Mike Manning <mmanning@brocade.com>
> Fixes: b6cb5ac8331b ("net: bridge: add per-port multicast flood flag")
> Fixes: 99f906e9ad7b ("bridge: add per-port broadcast flood flag")
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>

Applied and queued up for -stable, thanks.
