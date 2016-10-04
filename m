From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6 addrconf: disallow rtr_solicits < -1
Date: Tue, 04 Oct 2016 00:38:31 -0400 (EDT)
Message-ID: <20161004.003831.2056791273400961514.davem@davemloft.net>
References: <1475476917-17382-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: 8BIT
Cc: maze@google.com, netdev@vger.kernel.org, ek@google.com,
        lorenzo@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54330 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750780AbcJDEij (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 00:38:39 -0400
In-Reply-To: <1475476917-17382-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej ¯enczykowski <zenczykowski@gmail.com>
Date: Sun,  2 Oct 2016 23:41:57 -0700

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

Please remove the const qualifier and the casts to be consistent
with how we handle this elsewhere.

Thanks.
