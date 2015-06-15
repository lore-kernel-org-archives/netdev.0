From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Disable Granular QoS per VF under
 IB/Eth VPI configuration
Date: Mon, 15 Jun 2015 16:43:24 -0700 (PDT)
Message-ID: <20150615.164324.2223309998317923938.davem@davemloft.net>
References: <1434291186-24953-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dledford@redhat.com, amirv@mellanox.com,
	talal@mellanox.com, jackm@dev.mellanox.co.il, idos@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350AbbFOXnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 19:43:25 -0400
In-Reply-To: <1434291186-24953-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 14 Jun 2015 17:13:06 +0300

> Due to firmware bug, under VPI configuration when port1 = IB and
> port2 = Eth, Granular QoS per VF isn't working properly. More over,
> the whole QP0/QP1 Para-Virtualization in the mlx4 IB driver is
> broken on that config.
> 
> Hence, we must disable Granular QoS per VF under that configuration
> till a fix is introduced. Once that happens, a new device capability
> will be used to mark the feature support on that specific configuration.
> 
> Reported-by: Doug Ledford <dledford@redhat.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
