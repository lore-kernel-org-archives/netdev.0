From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: disable BH in set_ping_group_range()
Date: Thu, 20 Oct 2016 14:50:09 -0400 (EDT)
Message-ID: <20161020.145009.1159871260910222213.davem@davemloft.net>
References: <1476984408.7065.21.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, salo@google.com, xiyou.wangcong@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44728 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933863AbcJTSuL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2016 14:50:11 -0400
In-Reply-To: <1476984408.7065.21.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2016 10:26:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit 4ee3bd4a8c746 ("ipv4: disable BH when changing ip local port
> range") Cong added BH protection in set_local_port_range() but missed
> that same fix was needed in set_ping_group_range()
> 
> Fixes: b8f1a55639e6 ("udp: Add function to make source port for UDP tunnels")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Eric Salo <salo@google.com>

Applied and queued up for -stable.
