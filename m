From: Scott Wood <scottwood-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Subject: Re: [PATCH] Documentation: bindings: net: DPAA corenet binding
 document
Date: Tue, 2 Dec 2014 17:03:40 -0600
Message-ID: <1417561420.15957.221.camel@freescale.com>
References: <1417169426-11823-1-git-send-email-madalin.bucur@freescale.com>
	 <1417495189.15957.209.camel@freescale.com>
	 <BL2PR03MB545CC342CA6A408D2FD5CF6E67A0@BL2PR03MB545.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org" <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Medve Emilian-EMMEDVE1 <Emilian.Medve-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Liberman Igal-B31950 <Igal.Liberman-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org" <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Bucur Madalin-Cristian-B32716 <madalin.bucur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <BL2PR03MB545CC342CA6A408D2FD5CF6E67A0-AZ66ij2kwaa1tTsckATbNOO6mTEJWrR4XA4E9RH9d+qIuWR1G4zioA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-12-02 at 06:12 -0600, Bucur Madalin-Cristian-B32716 wrote:
> > -----Original Message-----
> > From: Wood Scott-B07421
> > Sent: Tuesday, December 02, 2014 6:40 AM
> > On Fri, 2014-11-28 at 12:10 +0200, Madalin Bucur wrote:
> > > Add the device tree binding document for the DPAA corenet node
> > > and DPAA Ethernet nodes.
> > >
> > > Signed-off-by: Madalin Bucur <madalin.bucur-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
> > > ---
> > >  Documentation/devicetree/bindings/net/fsl-dpaa.txt | 31
> > ++++++++++++++++++++++
> > >  1 file changed, 31 insertions(+)
> > >  create mode 100644 Documentation/devicetree/bindings/net/fsl-dpaa.txt
> > >
> > > diff --git a/Documentation/devicetree/bindings/net/fsl-dpaa.txt
> > b/Documentation/devicetree/bindings/net/fsl-dpaa.txt
> > > new file mode 100644
> > > index 0000000..822c668
> > > --- /dev/null
> > > +++ b/Documentation/devicetree/bindings/net/fsl-dpaa.txt
> > > @@ -0,0 +1,31 @@
> > > +*DPAA corenet
> > > +
> > > +The corenet bus containing all DPAA Ethernet nodes.
> > 
> > What does this have to do with corenet?
> > 
> The corenet-generic platform code uses this compatible.

That doesn't make it a "corenet bus".  It's not a bus at all.

> > > +Required property
> > > + - compatible: string property.  Must include "fsl,dpaa". Can include
> > > +   also "fsl,<SoC>-dpaa".
> > 
> > No need for the <SoC> part.  As we previously discussed, the only
> > purpose of this node is backwards compatibility with the U-Boot MAC
> > address fixup -- if U-Boot doesn't look for the <SoC> version, then
> > don't complicate things.
> > 
> > Though, I can't find where U-Boot references this node.  Are you sure
> > it's not using the ethernet%d aliases like everything else, in which
> > case why do we need this node at all?
> > 
> > -Scott
> > 
> 
> The initial (Freescale SDK) binding document contained those compatibles,
> not sure what the initial intent was for the <SoC> variants.
> 
> The "fsl,dpaa" node is of interest to the DPAA Ethernet because it is
> the parent of the "fsl,dpa-ethernet" nodes.

I'm not interested in what the SDK binding says, or what the SDK kernel
does.  I'm interested in whether there's a U-Boot compatibility issue,
as was previously alleged.  If there isn't, then there's no need for
fsl,dpaa *or* fsl,dpa-ethernet.

-Scott


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
