From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] mlxsw: pci: Implement reset done check
Date: Sun, 13 Mar 2016 22:30:24 -0400 (EDT)
Message-ID: <20160313.223024.1143192688898649418.davem@davemloft.net>
References: <1457647821-2839-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40575 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753266AbcCNCa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 22:30:27 -0400
In-Reply-To: <1457647821-2839-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 10 Mar 2016 23:10:21 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Firmware now tells us that the reset is done by passing a magic value
> via register. Use it to shorten the wait in case this is supported.
> With old firmware, we still wait until the timeout is reached.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
