From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Add LAN9352 Ethernet Driver
Date: Wed, 10 Feb 2016 05:33:58 -0500 (EST)
Message-ID: <20160210.053358.801208182711951209.davem@davemloft.net>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF199@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, corbet@lwn.net
To: Bryan.Whitehead@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbcBJKeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 05:34:06 -0500
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264402EF199@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Bryan.Whitehead@microchip.com>
Date: Tue, 9 Feb 2016 20:40:30 +0000

> +#ifdef USE_PHY_WORK_AROUND
> +#define MIN_PACKET_SIZE (64)
> +	char loopback_tx_pkt[MIN_PACKET_SIZE];
> +	char loopback_rx_pkt[MIN_PACKET_SIZE];
> +	unsigned int resetcount;
> +#endif
 ...
> +#define USE_PHY_WORK_AROUND

If you're going to unconditionally define this, and not provide a Kconfig
mechanism to change it, just get rid of this and the CPP tests upon it.

Thanks.
