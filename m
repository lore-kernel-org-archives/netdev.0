From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: fix dual EMAC stall when
 connected to same switch
Date: Sat, 21 Jun 2014 17:18:30 -0700 (PDT)
Message-ID: <20140621.171830.1024608044448040295.davem@davemloft.net>
References: <1403092308-31380-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yegorslists@googlemail.com, balbi@ti.com
To: mugunthanvnm@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40564 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751243AbaFVASd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jun 2014 20:18:33 -0400
In-Reply-To: <1403092308-31380-1-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Wed, 18 Jun 2014 17:21:48 +0530

> In commit 629c9a8fd0bbdfc6d702526b327470166ec39c6b (drivers: net: cpsw: Add
> default vlan for dual emac case also), api cpsw_add_default_vlan() also
> changes the port vlan which is required to seperate the ports which results
> in the following behavior
> 
> In Dual EMAC mode, when both the Etnernet connected is connected to same
> switch, it creates a loop in the switch and when a broadcast packet is
> received it is forwarded to the other port which stalls the whole switch
> and needs a reset/power cycle to the switch to recover. So intead of using
> the api, add only the default VLAN entry in dual EMAC case.
> 
> Cc: Yegor Yefremov <yegorslists@googlemail.com>
> Cc: Felipe Balbi <balbi@ti.com>
> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>

Applied and queued up for -stable, thanks.
