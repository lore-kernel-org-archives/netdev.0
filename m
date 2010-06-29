From: David Miller <davem@davemloft.net>
Subject: Re: [v4 Patch 2/2] mlx4: add dynamic LRO disable support
Date: Mon, 28 Jun 2010 23:04:59 -0700 (PDT)
Message-ID: <20100628.230459.232745316.davem@davemloft.net>
References: <20100622085415.5566.22523.sendpatchset@localhost.localdomain>
	<20100622085426.5566.51436.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sgruszka@redhat.com,
	herbert.xu@redhat.com, bhutchings@solarflare.com,
	Ramkrishna.Vepa@exar.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53701
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751950Ab0F2GEs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 02:04:48 -0400
In-Reply-To: <20100622085426.5566.51436.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amerigo Wang <amwang@redhat.com>
Date: Tue, 22 Jun 2010 04:50:17 -0400

> 
> This patch adds dynamic LRO diable support for mlx4 net driver.
> It also fixes a bug of mlx4, which checks NETIF_F_LRO flag in rx
> path without rtnl lock.
> 
> (I don't have mlx4 card, so only did compiling test. Anyone who wants
> to test this is more than welcome.)
> 
> This is based on Neil's initial work too, and heavily modified based
> on Stanislaw's suggestions.
> 
> Signed-off-by: WANG Cong <amwang@redhat.com>
> Signed-off-by: Neil Horman <nhorman@redhat.com>
> Acked-by: Neil Horman <nhorman@redhat.com>
> Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
> Cc: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-next-2.6

I'd really like the module options to just die as the dynamic
ethtool mechanism should be the only knob for this for consistency
with the rest of the drivers.
