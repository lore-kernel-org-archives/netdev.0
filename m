From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/4] atl1: Header files for Attansic L1 driver
Date: Mon, 22 Jan 2007 12:31:44 +0100
Message-ID: <20070122113144.GA26468@electric-eye.fr.zoreil.com>
References: <20070121210608.GC2702@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, shemminger@osdl.org, csnook@redhat.com,
	hch@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:49211 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751548AbXAVLdh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 06:33:37 -0500
To: Jay Cliburn <jacliburn@bellsouth.net>
Content-Disposition: inline
In-Reply-To: <20070121210608.GC2702@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> diff --git a/drivers/net/atl1/atl1_hw.h b/drivers/net/atl1/atl1_hw.h
> new file mode 100644
> index 0000000..0450b77
> --- /dev/null
> +++ b/drivers/net/atl1/atl1_hw.h
[...]
> +/*  MII definition */
> +/* PHY Common Register */
> +#define MII_BMCR					0x00
> +#define MII_BMSR					0x01
> +#define MII_PHYSID1					0x02
> +#define MII_PHYSID2					0x03
> +#define MII_ADVERTISE					0x04
> +#define MII_LPA						0x05
> +#define MII_EXPANSION					0x06
[snip]

It duplicates a lot of #define already available in include/linux/mii.h.

-- 
Ueimor
