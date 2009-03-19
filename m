From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH -next] fsl_pq_mdio: Revive Gianfar TBI PHY support
Date: Thu, 19 Mar 2009 10:56:59 -0500
Message-ID: <5D5BAD65-6ED3-4B07-9106-7DD2A715B6BA@freescale.com>
References: <20090319155232.GA5419@oksana.dev.rtsoft.ru>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Kumar Gala <galak@kernel.crashing.org>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:55545 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbZCSP53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 11:57:29 -0400
In-Reply-To: <20090319155232.GA5419@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 19, 2009, at 10:52 AM, Anton Vorontsov wrote:

> commit 1577ecef766650a57fceb171acee2b13cbfaf1d3 ("netdev: Merge UCC
> and gianfar MDIO bus drivers") broke the TSEC TBI PHY support: the
> driver now refuses to probe TBI MDIO buses as it doesn't know about
> "fsl,gianfar-tbi" compatible entry, and thus _probe() fails with
> -ENODEV status.
>
> Fix this by adding "fsl,gianfar-tbi" to the list of known Gianfar
> MDIO buses.
>
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Acked-by: Andy Fleming <afleming@freescale.com>


