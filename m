From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] rocker: free netdevice during netdevice removal
Date: Sun, 02 Aug 2015 18:04:41 -0700 (PDT)
Message-ID: <20150802.180441.2236361356970613614.davem@davemloft.net>
References: <1438536556-13154-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com, idosch@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38576 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789AbbHCBEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 21:04:44 -0400
In-Reply-To: <1438536556-13154-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Sun,  2 Aug 2015 19:29:16 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> When removing a port's netdevice in 'rocker_remove_ports', we should
> also free the allocated 'net_device' structure. Do that by calling
> 'free_netdev' after unregistering it.
> 
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Fixes: 4b8ac9660af ("rocker: introduce rocker switch driver")

Applied and queued up for -stable, thanks.
