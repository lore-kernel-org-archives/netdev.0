From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 1/2] arm: ixp4xx: set cohorent_dma_mask for ethernet platform devices
Date: Mon, 22 Jul 2013 16:49:27 +0200
Message-ID: <m3bo5uabuw.fsf@intrepid.localdomain>
References: <1374315339-31469-1-git-send-email-jogo@openwrt.org>
	<1374315339-31469-2-git-send-email-jogo@openwrt.org>
	<m3ip04ezty.fsf@intrepid.localdomain>
	<1374424823.2804.25.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jonas Gorski <jogo@openwrt.org>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <linux@arm.linux.org.uk>,
	"Imre Kaloz" <kaloz@openwrt.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inx.pm.waw.pl ([195.116.170.130]:52949 "EHLO inx.pm.waw.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756343Ab3GVOt3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jul 2013 10:49:29 -0400
In-Reply-To: <1374424823.2804.25.camel@deadeye.wl.decadent.org.uk> (Ben
	Hutchings's message of "Sun, 21 Jul 2013 17:40:23 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

> I think the problem is that the platform device and the platform data
> have not been properly separated.  The machine-specific setup functions
> should be passing the eth_plat_info and MAC ID into a common ixp4xx
> function which would then create the platform device with the correct
> DMA mask etc.

That's also my idea. Will look at this.
-- 
Krzysztof Halasa
