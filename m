From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: [PATCH,RFC] Marvell Orion SoC ethernet driver
Date: Tue, 16 Oct 2007 23:31:15 +0200
Message-ID: <1192570275.14601.10.camel@sakura.staff.proxad.net>
References: <20071016192806.GD19618@xi.wantstofly.org>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tzachi@marvell.com, nico@cam.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sakura.staff.proxad.net ([213.228.1.107]:57240 "EHLO
	sakura.staff.proxad.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935981AbXJPWIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 18:08:05 -0400
In-Reply-To: <20071016192806.GD19618@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2007-10-16 at 21:28 +0200, Lennert Buytenhek wrote:

Hello,

> +#define PORT_CONF		0x400
> +#define PORT_CONF_EXT		0x404
> +#define PORT_MAC_LO		0x414
> +#define PORT_MAC_HI		0x418
> +#define PORT_SDMA		0x41c
> +#define PORT_SERIAL		0x43c
> +#define PORT_STAT		0x444
> +#define PORT_TXQ_CMD		0x448
> +#define PORT_MTU		0x458
> +#define PORT_CAUSE		0x460
> +#define PORT_CAUSE_EXT		0x464
> +#define PORT_MASK		0x468
> +#define PORT_MASK_EXT		0x46c
> +#define PORT_TX_THRESH		0x474

This driver seems to support the same hardware as mv643xx_eth, any
chance you could use it to avoid code duplication ?

Regards,

-- 
Maxime

