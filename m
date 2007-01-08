From: "Li Yang-r58472" <LeoLi@freescale.com>
Subject: RE: [PATCH 2.6.20-rc3] UCC Ether driver: kmalloc casting cleanups
Date: Mon, 8 Jan 2007 15:28:20 +0800
Message-ID: <989B956029373F45A0B8AF029708189008656E@zch01exm26.fsl.freescale.net>
References: <20070108042657.GA18610@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751469AbXAHH1P@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20070108042657.GA18610@Ahmed>
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Ahmed S. Darwish [mailto:darwish.07@gmail.com]
> Sent: Monday, January 08, 2007 12:27 PM
> To: Li Yang-r58472
> Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [PATCH 2.6.20-rc3] UCC Ether driver: kmalloc casting
cleanups
> 
> On Mon, Jan 08, 2007 at 11:12:28AM +0800, Li Yang-r58472 wrote:
> > > From: Ahmed S. Darwish [mailto:darwish.07@gmail.com]
> > >
> > > Hi,
> > > A kmalloc casting cleanup patch.
> > > Signed-off-by: Ahmed Darwish <darwish.07@gmail.com>
> 
> [..]
> 
> > > -				(u32) (kmalloc((u32) (length + align),
> > > -				GFP_KERNEL));
> > > +				kmalloc((u32) (length + align),
GFP_KERNEL);
> > > +
> > >  			if (ugeth->tx_bd_ring_offset[j] != 0)
> > >  				ugeth->p_tx_bd_ring[j] =
> 
> [..]
> 
> > > -			    (u32) (kmalloc((u32) (length + align),
GFP_KERNEL));
> > > +				kmalloc((u32) (length + align),
GFP_KERNEL);
> >
> > NACK about the 2 clean-ups above.  Cast from pointer to integer is
> > required here.
> 
> Are the casts from pointer to integer just needed to suppress gcc
> warnings or there's something technically important about them ?

It is to suppress the warnings.  IMHO, most type casts are not
technically important but for sanity check.

- Leo
