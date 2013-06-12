From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: Store port number in private data, not
 net_device::dev_id
Date: Wed, 12 Jun 2013 03:15:16 -0700 (PDT)
Message-ID: <20130612.031516.153223282530581370.davem@davemloft.net>
References: <1370883797.1933.14.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	narendra_k@dell.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52522 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753316Ab3FLKPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 06:15:17 -0400
In-Reply-To: <1370883797.1933.14.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 10 Jun 2013 18:03:17 +0100

> We should not use net_device::dev_id to indicate the port number, as
> this affects the way the local part of IPv6 addresses is normally
> generated.
> 
> This field was intended for use where multiple devices may share a
> single assigned MAC address and need to have different IPv6 addresses.
> Siena's two ports each have their own MAC addresses.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks Ben.
