From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next RESEND 1/1] driver: ipvlan: Remove unnecessary
 ipvlan NULL check in ipvlan_count_rx
Date: Wed, 28 Dec 2016 14:24:53 -0500 (EST)
Message-ID: <20161228.142453.1647994910230714441.davem@davemloft.net>
References: <1482914862-2793-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maheshb@google.com, edumazet@google.com, netdev@vger.kernel.org,
        gfree.wind@gmail.com
To: fgao@ikuai8.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44096 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbcL1TY5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 14:24:57 -0500
In-Reply-To: <1482914862-2793-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fgao@ikuai8.com
Date: Wed, 28 Dec 2016 16:47:42 +0800

> From: Gao Feng <fgao@ikuai8.com>
> 
> There are three functions which would invoke the ipvlan_count_rx. They
> are ipvlan_process_multicast, ipvlan_rcv_frame, and ipvlan_nf_input.
> The former two functions already use the ipvlan directly before
> ipvlan_count_rx, and ipvlan_nf_input gets the ipvlan from
> ipvl_addr->master, it is not possible to be NULL too.
> So the ipvlan pointer check is unnecessary in ipvlan_count_rx.
> 
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Applied.
