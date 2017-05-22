From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macsec: double accounting of dropped rx/tx
 packets
Date: Mon, 22 May 2017 11:55:48 -0400 (EDT)
Message-ID: <20170522.115548.899380883537075549.davem@davemloft.net>
References: <1495232744-17075-1-git-send-email-girish.moodalbail@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net
To: girish.moodalbail@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53602 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752181AbdEVPzy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 11:55:54 -0400
In-Reply-To: <1495232744-17075-1-git-send-email-girish.moodalbail@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Girish Moodalbail <girish.moodalbail@oracle.com>
Date: Fri, 19 May 2017 15:25:44 -0700

> The macsec implementation shouldn't account for rx/tx packets that are
> dropped in the netdev framework. The netdev framework itself accounts
> for such packets by atomically updating struct net_device`rx_dropped and
> struct net_device`tx_dropped fields. Later on when the stats for macsec
> link is retrieved, the packets dropped in netdev framework will be
> included in dev_get_stats() after calling macsec.c`macsec_get_stats64()
> 
> Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>

This looks correct to me.

Applied, thank you.
