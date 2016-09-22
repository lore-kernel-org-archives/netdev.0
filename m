From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 2/2] net: skbuff: Coding: Use
 eth_type_vlan() instead of open coding it
Date: Thu, 22 Sep 2016 01:36:35 -0400 (EDT)
Message-ID: <20160922.013635.452704267252998169.davem@davemloft.net>
References: <1474364917-31710-1-git-send-email-shmulik.ladkani@gmail.com>
        <1474364917-31710-2-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, daniel@iogearbox.net, pshelar@ovn.org,
        eric.dumazet@gmail.com, netdev@vger.kernel.org,
        shmulik.ladkani@gmail.com
To: shmulik.ladkani@ravellosystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54670 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755262AbcIVFgi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 01:36:38 -0400
In-Reply-To: <1474364917-31710-2-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Date: Tue, 20 Sep 2016 12:48:37 +0300

> Fix 'skb_vlan_pop' to use eth_type_vlan instead of directly comparing
> skb->protocol to ETH_P_8021Q or ETH_P_8021AD.
> 
> Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>

Applied.
