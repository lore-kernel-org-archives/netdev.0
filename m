From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv6: remove skb_reserve in getroute
Date: Thu, 26 Jan 2017 18:38:07 -0500 (EST)
Message-ID: <20170126.183807.1779960028908976591.davem@davemloft.net>
References: <1485468516-4750-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52164 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753658AbdAZXih (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 18:38:37 -0500
In-Reply-To: <1485468516-4750-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu, 26 Jan 2017 14:08:36 -0800

> Remove skb_reserve and skb_reset_mac_header from inet6_rtm_getroute. The
> allocated skb is not passed through the routing engine (like it is for
> IPv4) and has not since the beginning of git time.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Good catch, applied, thanks David.
