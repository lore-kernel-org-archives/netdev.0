From: "chaithrika" <chaithrika@ti.com>
Subject: RE: [PATCH v2] net-next-2.6: TI DaVinci EMAC driver
Date: Thu, 21 May 2009 16:59:45 +0530
Message-ID: <044201c9da07$716aa310$543fe930$@com>
References: <1242646472-13422-1-git-send-email-chaithrika@ti.com> <20090518.151954.121982430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>, <nsekahr@ti.com>,
	<anantgole@ti.com>, <khilman@deeprootsystems.com>
To: "'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:52397 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752493AbZEULaX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2009 07:30:23 -0400
In-Reply-To: <20090518.151954.121982430.davem@davemloft.net>
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David,

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, May 19, 2009 3:50 AM
> To: chaithrika@ti.com
> Cc: netdev@vger.kernel.org; davinci-linux-open-
> source@linux.davincidsp.com; nsekahr@ti.com; anantgole@ti.com;
> khilman@deeprootsystems.com
> Subject: Re: [PATCH v2] net-next-2.6: TI DaVinci EMAC driver
> 
> From: Chaithrika U S <chaithrika@ti.com>
> Date: Mon, 18 May 2009 07:34:32 -0400
> 
> > Add support for TI DaVinci EMAC driver.
> >
> > TI DaVinci Ethernet Media Access Controller module is based upon
> > TI CPPI 3.0 DMA engine and supports 10/100 Mbps on all and Gigabit
> modes on
> > some TI devices. It supports MII/RMII and has up to 8Kbytes of
> internal
> > descriptor memory. This driver has been working on several TI devices
> including
> > DM644x, DM646x and DA830 platforms. The specs of this device are
> available at:
> > http://www.ti.com/litv/pdf/sprue24a
> >
> > Signed-off-by: Anant Gole <anantgole@ti.com>
> > Signed-off-by: Kevin Hilman <khilman@deeprootsystems.com>
> > Signed-off-by: Chaithrika U S <chaithrika@ti.com>
> 
> Applied, thanks.
> 

Thanks.

> BTW, DECLARE_MAC_BUF(), print_mac() et al. is deprecated, you can
> simply use the printf format specifier "%pM" to print MAC addresses
> directly.

OK. Will submit a patch for this.

Regards,
Chaithrika



