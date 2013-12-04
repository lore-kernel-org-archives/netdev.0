From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [PATCH] xen/pvhvm: If xen_platform_pci=0 is set don't blow up.
Date: Wed, 4 Dec 2013 09:08:37 -0800
Message-ID: <20131204170837.GB8838@core.coreip.homeip.net>
References: <1386105246-14337-1-git-send-email-konrad.wilk@oracle.com>
 <20131204164218.GA8838@core.coreip.homeip.net>
 <20131204164802.GG391@pegasus.dumpdata.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefano.stabellini@eu.citrix.com, ian.campbell@citrix.com,
	xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
	boris.ostrovsky@oracle.com, david.vrabel@citrix.com,
	leosilva@linux.vnet.ibm.com, ashley@ashleylai.com,
	peterhuewe@gmx.de, mail@srajiv.net, tpmdd@selhorst.net,
	tpmdd@sirrix.com, bhelgaas@google.com, plagnioj@jcrosoft.com,
	tomi.valkeinen@ti.com, tpmdd-devel@lists.sourceforge.net,
	linux-input@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, linux-fbdev@vger.kernel.org
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-input-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131204164802.GG391@pegasus.dumpdata.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 04, 2013 at 11:48:03AM -0500, Konrad Rzeszutek Wilk wrote:
> > > which is hardly nice. This patch fixes this by having each
> > > PV driver check for:
> > >  - if running in PV, then it is fine to execute (as that is their
> > >    native environment).
> > >  - if running in HVM, check if user wanted 'xen_emul_unplug=never',
> > >    in which case bail out and don't load PV drivers.
> > >  - if running in HVM, and if PCI device 5853:0001 (xen_platform_pci)
> > >    does not exist, then bail out and not load PV drivers.
> > > 
> > > P.S.
> > > Ian Campbell suggested getting rid of 'xen_platform_pci_unplug'
> > > but unfortunatly the xen-blkfront driver is using it, so we
> > > cannot do it.
> > > 
> > > Reported-by: Sander Eikelenboom <linux@eikelenboom.it
> > > Reported-by: Anthony PERARD <anthony.perard@citrix.com>
> > > Reported-by: Fabio Fantoni <fabio.fantoni@m2r.biz>
> > 
> > For input:
> > 
> > Acked-by: Dmitry Torokhov <dmitry.torokhov@gmail.com>
> 
> Thank you. I need to do some extra changes to the other subsystems but
> for the fb/kbd itshould be still throught the same function as this
> patch has exposed. I will repost it and include your Ack if you are OK
> with that?

Sure.

-- 
Dmitry
