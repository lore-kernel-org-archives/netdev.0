From: Scott Wood <scottwood@freescale.com>
Subject: Re: [V5, 2/6] fsl/fman: Add FMan support
Date: Thu, 29 Oct 2015 10:24:39 -0500
Message-ID: <1446132279.701.368.camel@freescale.com>
References: <1442836354-5445-1-git-send-email-igal.liberman@freescale.com>
	 <20150925230153.GA4626@home.buserror.net>
	 <BL2PR03MB5006080090B6783629A33A5E6220@BL2PR03MB500.namprd03.prod.outlook.com>
	 <1446067854.701.365.camel@freescale.com>
	 <DM2PR03MB509C1B1A5272C9D0A9F8295E6200@DM2PR03MB509.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Bucur Madalin-Cristian-B32716" <madalin.bucur@freescale.com>
To: Liberman Igal-B31950 <Igal.Liberman@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DM2PR03MB509C1B1A5272C9D0A9F8295E6200@DM2PR03MB509.namprd03.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-10-29 at 10:22 -0500, Liberman Igal-B31950 wrote:
> Regards,
> Igal Liberman
> 
> > -----Original Message-----
> > From: Wood Scott-B07421
> > Sent: Wednesday, October 28, 2015 11:31 PM
> > To: Liberman Igal-B31950 <Igal.Liberman@freescale.com>
> > Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org; linux-
> > kernel@vger.kernel.org; Bucur Madalin-Cristian-B32716
> > <madalin.bucur@freescale.com>
> > Subject: Re: [V5, 2/6] fsl/fman: Add FMan support
> > 
> > On Tue, 2015-10-27 at 11:32 -0500, Liberman Igal-B31950 wrote:
> > 
> > > > > +
> > > > > +struct device *fman_get_device(struct fman *fman) {  return
> > > > > +fman->dev; }
> > > > 
> > > > Is this really necessary?
> > > > 
> > > 
> > > Fman port needs fman->dev, fman structure is opaque, so yes, it's 
> > > needed.
> > 
> > Why is opacity being maintained from one part of the fman driver to
> > another?
> > Isn't this the sort of excessive layering that was complained about?
> > 
> > 
> 
> It's not really layering.
> Fman Port uses Fman resources, it's not completely standalone. 

That's my point -- if it's not standalone, why is "struct fman" opaque to the 
port code?

-Scott
