From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next] Add LAN9352 Ethernet Driver
Date: Wed, 10 Feb 2016 18:26:01 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264402EF2F0@CHN-SV-EXMX02.mchp-main.com>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF199@CHN-SV-EXMX02.mchp-main.com>
 <20160210.053358.801208182711951209.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <corbet@lwn.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:65081 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752463AbcBJS0F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 13:26:05 -0500
In-Reply-To: <20160210.053358.801208182711951209.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David,

I'll submit a revised patch soon.

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Wednesday, February 10, 2016 5:34 AM
To: Bryan Whitehead - C21958
Cc: netdev@vger.kernel.org; corbet@lwn.net
Subject: Re: [PATCH net-next] Add LAN9352 Ethernet Driver

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

If you're going to unconditionally define this, and not provide a Kconfig mechanism to change it, just get rid of this and the CPP tests upon it.

Thanks.
