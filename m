From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net-next-2.6: TI DaVinci EMAC driver
Date: Mon, 18 May 2009 15:19:54 -0700 (PDT)
Message-ID: <20090518.151954.121982430.davem@davemloft.net>
References: <1242646472-13422-1-git-send-email-chaithrika@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com, nsekahr@ti.com,
	anantgole@ti.com, khilman@deeprootsystems.com
To: chaithrika@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36114
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750898AbZERWT4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 18:19:56 -0400
In-Reply-To: <1242646472-13422-1-git-send-email-chaithrika@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chaithrika U S <chaithrika@ti.com>
Date: Mon, 18 May 2009 07:34:32 -0400

> Add support for TI DaVinci EMAC driver.
> 
> TI DaVinci Ethernet Media Access Controller module is based upon
> TI CPPI 3.0 DMA engine and supports 10/100 Mbps on all and Gigabit modes on
> some TI devices. It supports MII/RMII and has up to 8Kbytes of internal
> descriptor memory. This driver has been working on several TI devices including
> DM644x, DM646x and DA830 platforms. The specs of this device are available at:
> http://www.ti.com/litv/pdf/sprue24a
> 
> Signed-off-by: Anant Gole <anantgole@ti.com>
> Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>
> Signed-off-by: Chaithrika U S <chaithrika@ti.com>

Applied, thanks.

BTW, DECLARE_MAC_BUF(), print_mac() et al. is deprecated, you can
simply use the printf format specifier "%pM" to print MAC addresses
directly.
