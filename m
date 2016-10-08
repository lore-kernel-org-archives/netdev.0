From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv6 addrconf: disallow rtr_solicits < -1
Date: Fri, 07 Oct 2016 23:44:21 -0400 (EDT)
Message-ID: <20161007.234421.1323207153848674724.davem@davemloft.net>
References: <CANP3RGdVquyFe1VA2mKMC1HNgnXPhmpsv45R-7P6boWCb8oC2A@mail.gmail.com>
        <1475827249-27318-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: maze@google.com, netdev@vger.kernel.org, ek@google.com,
        lorenzo@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59876 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752065AbcJHDo3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 23:44:29 -0400
In-Reply-To: <1475827249-27318-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej ¯enczykowski <zenczykowski@gmail.com>
Date: Fri,  7 Oct 2016 01:00:49 -0700

> From: Maciej ¯enczykowski <maze@google.com>
> 
> This disallows setting /proc/sys/net/ipv6/conf/*/router_solicitations
> to values below -1.
> 
> -1 continues to mean an unlimited number of retransmits.
> 
> Note: this depends on 'ipv6 addrconf: remove addrconf_sysctl_hop_limit()'
> 
> Signed-off-by: Maciej ¯enczykowski <maze@google.com>

Applied, thanks.
