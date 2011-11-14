From: Fleming Andy-AFLEMING <afleming@freescale.com>
Subject: Re: [PATCH] net: fsl_pq_mdio: fix non tbi phy access
Date: Mon, 14 Nov 2011 21:04:47 +0000
Message-ID: <C89A2124-7AB4-45B6-ACD1-8C5936027531@freescale.com>
References: <b693b45a689d42b60a8a9e29dcdd2fb27e20df82.1321251618.git.baruch@tkos.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Baruch Siach <baruch@tkos.co.il>
To: Baruch Siach <baruch@tkos.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:32597 "EHLO
	TX2EHSOBE009.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754819Ab1KNVEu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 16:04:50 -0500
In-Reply-To: <b693b45a689d42b60a8a9e29dcdd2fb27e20df82.1321251618.git.baruch@tkos.co.il>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Well, this got applied quickly, so I guess I can't NAK, but this requires discussion.

On Nov 14, 2011, at 0:22, "Baruch Siach" <baruch@tkos.co.il> wrote:

> Since 952c5ca1 (fsl_pq_mdio: Clean up tbi address configuration) .probe returns
> -EBUSY when the "tbi-phy" node is missing. Fix this.

It returns an error because it finds no tbi node. Because without the tbi node, there is no way for the driver to determine which address to set.

Your solution is to ignore the error, and hope. That's a broken approach. The real solution for a p1010 should be to have a tbi node in the dts.

And looking at the p1010si.dtsi, I see that it's automatically there for you.

How were you breaking?

Andy
