From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix wraparound issue in tcp_lp
Date: Tue, 02 May 2017 15:07:30 -0400 (EDT)
Message-ID: <20170502.150730.1139051201957624561.davem@davemloft.net>
References: <1493677788.31837.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52788 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdEBTHb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 15:07:31 -0400
In-Reply-To: <1493677788.31837.25.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 01 May 2017 15:29:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Be careful when comparing tcp_time_stamp to some u32 quantity,
> otherwise result can be surprising.
> 
> Fixes: 7c106d7e782b ("[TCP]: TCP Low Priority congestion control")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks.
