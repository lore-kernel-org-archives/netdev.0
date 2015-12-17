From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] team: Advertise tunneling offload features
Date: Thu, 17 Dec 2015 16:24:49 -0500 (EST)
Message-ID: <20151217.162449.2133225661920779627.davem@davemloft.net>
References: <1450361515-23594-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com,
	jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57239 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932333AbbLQVYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2015 16:24:51 -0500
In-Reply-To: <1450361515-23594-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 17 Dec 2015 16:11:55 +0200

> From: Eran Ben Elisha <eranbe@mellanox.com>
> 
> When the underlying device supports offloads encapulated traffic,
> we need to reflect that through the hw_enc_features field of the
> team net-device.
> 
> This will cause the xmit path in the core networking stack to provide
> team with encapsulated GSO frames to offload into the HW etc.
> 
> Using this over Mellanox ConnectX3-pro (mlx4 driver) card that supports
> VXLAN offloads we got 36.0 Gbits/sec using eight iperf streams.
> 
> Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
> Acked-by: Jiri Pirko <jiri@mellanox.com>

Applied, thanks.
