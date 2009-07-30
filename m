From: Meelis Roos <mroos@linux.ee>
Subject: Re: [PATCH net-2.6] net: restore the original spinlock to protect
 unicast list
Date: Thu, 30 Jul 2009 15:38:29 +0300 (EEST)
Message-ID: <Pine.SOC.4.64.0907301537280.15557@math.ut.ee>
References: <Pine.SOC.4.64.0907301114150.10041@math.ut.ee> <4A71630A.9080105@gmail.com>
 <20090730110612.GD3686@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	davem@davemloft.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:47710 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750759AbZG3Mi3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jul 2009 08:38:29 -0400
In-Reply-To: <20090730110612.GD3686@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> There is a path when an assetion in dev_unicast_sync() appears. 
> 
> igmp6_group_added -> dev_mc_add -> __dev_set_rx_mode ->
> -> vlan_dev_set_rx_mode -> dev_unicast_sync
> 
> Therefore we cannot protect this list with rtnl. This patch restores the
> original protecting this list with spinlock.

Thank you, it works for me!

Tested-by: Meelis Roos <mroos@linux.ee>

-- 
Meelis Roos (mroos@linux.ee)
