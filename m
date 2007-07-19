From: Jon Loeliger <jdl@freescale.com>
Subject: Re: [PATCH 1/2] Fix error checking in Vitesse IRQ config
Date: Thu, 19 Jul 2007 11:49:42 -0500
Message-ID: <1184863782.16820.10.camel@ld0161-tx32>
References: <11847405503115-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linuxppc-dev@ozlabs.org" <linuxppc-dev@ozlabs.org>
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:62583 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933360AbXGSQtu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 12:49:50 -0400
In-Reply-To: <11847405503115-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-18 at 01:35, Andy Fleming wrote:
> phy_read() returns a negative number if there's an error, but the
> error-checking code in the Vitesse driver's config_intr function
> triggers if phy_read() returns non-zero.  Correct that.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
> I made a really stupid mistake in the 4 patches I sent out, earlier.  I
> thought those patches had been tested, but they hadn't been.  This one
> corrects a tiny error in the patch, and they have now been tested.  As before
> this change can be pulled from:
> 
> http://opensource.freescale.com/pub/scm/linux-2.6-85xx.git netdev
> 
> Really, REALLY sorry about that.  I have been given a paper bag of appropriate
> size and shape to fit over my head.
> 
>  drivers/net/phy/vitesse.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/phy/vitesse.c b/drivers/net/phy/vitesse.c
> index 6a53856..8874497 100644


Acked-by: Jon Loeliger <jdl@freescale.com>

Tested on the 8641HPCN.

Thanks,
jdl


