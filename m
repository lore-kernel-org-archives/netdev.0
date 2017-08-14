From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: vrf: Support for local traffic with
 sockets bound to enslaved devices
Date: Sun, 13 Aug 2017 20:05:30 -0700 (PDT)
Message-ID: <20170813.200530.2012776208539860355.davem@davemloft.net>
References: <1502496675-13349-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50338 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752175AbdHNDFb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 23:05:31 -0400
In-Reply-To: <1502496675-13349-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Fri, 11 Aug 2017 17:11:13 -0700

> This set gets local traffic working for sockets bound to enslaved
> devices. The local rtable and rt6_info added in June 2016 to get
> local traffic in VRFs working is no longer needed and actually
> keeps local traffic for sockets bound to an enslaved device from
> working. Patch 1 removes them.
> 
> Patch 2 adds a fix up for IPv4 IP_PKTINFO to return rt_iif for
> packets sent over the VRF device. This is similar to the handling
> of loopback.

Series applied, thanks David.
