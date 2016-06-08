From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v4 3/7] binding: mdio-mux: Add DT binding doc for
 Broadcom MDIO bus multiplexer
Date: Wed, 8 Jun 2016 14:40:43 -0500
Message-ID: <20160608194043.GA32093@rob-hp-laptop>
References: <1465216900-11755-1-git-send-email-pramod.kumar@broadcom.com>
 <1465216900-11755-4-git-send-email-pramod.kumar@broadcom.com>
 <5755C290.2020704@gmail.com>
 <f6cd5df22ef8ea070d7b35e628b6d25a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Kishon Vijay Abraham I <kishon@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	bcm-kernel-feedback-list@broadcom.com,
	linux-arm-kernel@lists.infradead.org
To: Pramod Kumar <pramod.kumar@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:36251 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422872AbcFHTkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 15:40:45 -0400
Content-Disposition: inline
In-Reply-To: <f6cd5df22ef8ea070d7b35e628b6d25a@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 07, 2016 at 05:27:29PM +0530, Pramod Kumar wrote:
> Hi Florian,
> 
> > -----Original Message-----
> > From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> > Sent: 07 June 2016 00:06
> > To: Pramod Kumar; Rob Herring; Pawel Moll; Mark Rutland; Ian Campbell;
> > Kumar Gala; Catalin Marinas; Will Deacon; Kishon Vijay Abraham I; David S.
> > Miller
> > Cc: devicetree@vger.kernel.org; netdev@vger.kernel.org; linux-
> > kernel@vger.kernel.org; bcm-kernel-feedback-list@broadcom.com; linux-arm-
> > kernel@lists.infradead.org
> > Subject: Re: [PATCH v4 3/7] binding: mdio-mux: Add DT binding doc for
> > Broadcom MDIO bus multiplexer
> >
> > On 06/06/2016 05:41 AM, Pramod Kumar wrote:
> > > Add DT binding doc for Broadcom MDIO bus multiplexer driver.
> > >
> > > Reviewed-by: Andrew Lunn <andrew@lunn.ch>
> > > Signed-off-by: Pramod Kumar <pramod.kumar@broadcom.com>
> >
> > Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> >
> >
> > > +for example:
> > > +		mdio_mux_iproc: mdio-mux@6602023c {
> >
> > I think Rob wanted you to drop the underscores here in favor of dashes,
> > there
> > are more below, not critical imho.
> >
> 
> I'd changed node name in favor of dashes. I don't think Label could be
> written with hyphens,"-".  "-" in label provides DT parsing error.

Right. Labels don't matter as they aren't part of the binding.

Rob
