From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: fsl_pq_mdio: Clean up tbi address configuration
Date: Mon, 14 Nov 2011 08:13:35 +0200
Message-ID: <20111114061335.GA13389@sapphire.tkos.co.il>
References: <1321024239-18861-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:37664 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751054Ab1KNGNs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 01:13:48 -0500
Content-Disposition: inline
In-Reply-To: <1321024239-18861-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

On Fri, Nov 11, 2011 at 05:10:39AM -0000, Andy Fleming wrote:
> The code for setting the address of the internal TBI PHY was
> convoluted enough without a maze of ifdefs. Clean it up a bit
> so we allow the logic to fail down to -ENODEV at the end of
> the if/else ladder, rather than using ifdefs to repeat the same
> failure code over and over.
> 
> Also, remove the support for the auto-configuration. I'm not aware of
> anyone using it, and it ends up using the bus mutex before it's been
> initialized.

With this applied I'm getting

fsl-pq_mdio: probe of ffe24000.mdio failed with error -16

on my P1011 board which does not have a "tbi-phy" node. I'll post a fix 
shortly.

baruch

> Signed-off-by: Andy Fleming <afleming@freescale.com>

baruch

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
