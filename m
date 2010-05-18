From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net/usb/asix.c Fix unaligned access
Date: Mon, 17 May 2010 17:18:39 -0700 (PDT)
Message-ID: <20100517.171839.39191543.davem@davemloft.net>
References: <s2q91f916b91005060413pe1a1799etdea5ad730841a04e@mail.gmail.com>
	<AANLkTiliFhlbe7HAOyn9O3935MkmEuRumLKYY7Ew4DXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: neiljay@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43013
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753591Ab0ERASa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 20:18:30 -0400
In-Reply-To: <AANLkTiliFhlbe7HAOyn9O3935MkmEuRumLKYY7Ew4DXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Jones <neiljay@gmail.com>
Date: Mon, 10 May 2010 17:06:01 +0100

> Using this driver can cause unaligned accesses in the IP layer
> This has been fixed by aligning the skb data correctly using the
> spare room left over by the 4 byte header inserted between packets
> by the device.
> 
> Signed-off-by: Neil Jones <NeilJay@gmail.com>

Applied, thanks.
