From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH] net: fsl_pq_mdio: fix non tbi phy access
Date: Tue, 15 Nov 2011 07:17:14 +0200
Message-ID: <20111115051713.GA4052@sapphire.tkos.co.il>
References: <b693b45a689d42b60a8a9e29dcdd2fb27e20df82.1321251618.git.baruch@tkos.co.il>
 <C89A2124-7AB4-45B6-ACD1-8C5936027531@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linuxppc-dev@lists.ozlabs.org
To: Fleming Andy-AFLEMING <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:47471 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750811Ab1KOFRf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 00:17:35 -0500
Content-Disposition: inline
In-Reply-To: <C89A2124-7AB4-45B6-ACD1-8C5936027531@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andy,

On Mon, Nov 14, 2011 at 09:04:47PM +0000, Fleming Andy-AFLEMING wrote:
> Well, this got applied quickly, so I guess I can't NAK, but this requires discussion.
> 
> On Nov 14, 2011, at 0:22, "Baruch Siach" <baruch@tkos.co.il> wrote:
> 
> > Since 952c5ca1 (fsl_pq_mdio: Clean up tbi address configuration) .probe returns
> > -EBUSY when the "tbi-phy" node is missing. Fix this.
> 
> It returns an error because it finds no tbi node. Because without the tbi 
> node, there is no way for the driver to determine which address to set.
> 
> Your solution is to ignore the error, and hope. That's a broken approach.  
> The real solution for a p1010 should be to have a tbi node in the dts.

Can you elaborate a bit on why this approach is broken? The PHY used to work 
for me until 952c5ca1, and with this applied.

> And looking at the p1010si.dtsi, I see that it's automatically there for 
> you.
> 
> How were you breaking?

Adding linuxppc to Cc.

My board is P1011 based, the single core version of P1020, not P1010. In 
p1020si.dtsi I see no tbi node. In p1020rdb.dts I see a tbi node but only for 
mdio@25000, not mdio@24000, which is what I'm using.

Am I missing something?

baruch

-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
