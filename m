From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net: restore the original spinlock to protect
 unicast list
Date: Sun, 02 Aug 2009 12:29:27 -0700 (PDT)
Message-ID: <20090802.122927.17579898.davem@davemloft.net>
References: <Pine.SOC.4.64.0907301114150.10041@math.ut.ee>
	<4A71630A.9080105@gmail.com>
	<20090730110612.GD3686@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mroos@linux.ee, eric.dumazet@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44875
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753391AbZHBT3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 15:29:19 -0400
In-Reply-To: <20090730110612.GD3686@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 30 Jul 2009 13:06:12 +0200

> There is a path when an assetion in dev_unicast_sync() appears. 
> 
> igmp6_group_added -> dev_mc_add -> __dev_set_rx_mode ->
> -> vlan_dev_set_rx_mode -> dev_unicast_sync
> 
> Therefore we cannot protect this list with rtnl. This patch restores the
> original protecting this list with spinlock.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks.
