From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip_gre: ipgre_tap device should keep dst
Date: Sun, 01 Oct 2017 03:54:47 +0100 (WEST)
Message-ID: <20171001.035447.305390891895301594.davem@davemloft.net>
References: <af0a18f43bc27a26ca1f3bce3730edcb312c9f76.1506576211.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33868 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750844AbdJACyt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 22:54:49 -0400
In-Reply-To: <af0a18f43bc27a26ca1f3bce3730edcb312c9f76.1506576211.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 28 Sep 2017 13:23:31 +0800

> Without keeping dst, the tunnel will not update any mtu/pmtu info,
> since it does not have a dst on the skb.
> 
> Reproducer:
>   client(ipgre_tap1 - eth1) <-----> (eth1 - ipgre_tap1)server
> 
> After reducing eth1's mtu on client, then perforamnce became 0.
> 
> This patch is to netif_keep_dst in gre_tap_init, as ipgre does.
> 
> Reported-by: Jianlin Shi <jishi@redhat.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied and queued up for -stable.
