From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: Re: [PATCH 2.6.20-rc3] UCC Ether driver: kmalloc casting cleanups
Date: Mon, 8 Jan 2007 06:26:57 +0200
Message-ID: <20070108042657.GA18610@Ahmed>
References: <20070106131832.GE19020@Ahmed> <989B956029373F45A0B8AF029708189006134E@zch01exm26.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:38694 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030498AbXAHE1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Jan 2007 23:27:30 -0500
Received: by nf-out-0910.google.com with SMTP id o25so9369993nfa
        for <netdev@vger.kernel.org>; Sun, 07 Jan 2007 20:27:29 -0800 (PST)
To: Li Yang-r58472 <LeoLi@freescale.com>
Content-Disposition: inline
In-Reply-To: <989B956029373F45A0B8AF029708189006134E@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 08, 2007 at 11:12:28AM +0800, Li Yang-r58472 wrote:
> > From: Ahmed S. Darwish [mailto:darwish.07@gmail.com]
> > 
> > Hi,
> > A kmalloc casting cleanup patch.
> > Signed-off-by: Ahmed Darwish <darwish.07@gmail.com>

[..]

> > -				(u32) (kmalloc((u32) (length + align),
> > -				GFP_KERNEL));
> > +				kmalloc((u32) (length + align), GFP_KERNEL);
> > +
> >  			if (ugeth->tx_bd_ring_offset[j] != 0)
> >  				ugeth->p_tx_bd_ring[j] =

[..]

> > -			    (u32) (kmalloc((u32) (length + align), GFP_KERNEL));
> > +				kmalloc((u32) (length + align), GFP_KERNEL);
> 
> NACK about the 2 clean-ups above.  Cast from pointer to integer is
> required here.

Are the casts from pointer to integer just needed to suppress gcc 
warnings or there's something technically important about them ?

I'll send the modified patch without the NACKed parts in minutes ..

-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
