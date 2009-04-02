From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fsl_pq_mdio: Revive UCC MDIO support
Date: Thu, 02 Apr 2009 01:28:13 -0700 (PDT)
Message-ID: <20090402.012813.163966172.davem@davemloft.net>
References: <20090331183352.GA4474@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Joakim.Tjernlund@transmode.se, afleming@freescale.com,
	leoli@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57094
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756094AbZDBI2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 04:28:25 -0400
In-Reply-To: <20090331183352.GA4474@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Tue, 31 Mar 2009 22:33:52 +0400

> commit 1577ecef766650a57fceb171acee2b13cbfaf1d3 ("netdev: Merge UCC
> and gianfar MDIO bus drivers") introduced a regression so that UCC
> MDIO buses no longer work.
> 
> This is because fsl_pq_mdio driver wrongly masks all non-TBI PHYs
> for !fsl,gianfar-mdio buses, while it should do that only for
> fsl,gianfar-tbi buses.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied, thanks.
