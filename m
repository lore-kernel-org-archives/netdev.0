From: Guennadi Liakhovetski <g.liakhovetski-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [PATCH/RFC 2/3] ethernet: add a PHY reset GPIO DT binding to
 sh_eth
Date: Mon, 8 Jul 2013 12:49:47 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1307081247530.19819@axis700.grange>
References: <1359043653-11374-1-git-send-email-g.liakhovetski@gmx.de>
 <1359043653-11374-3-git-send-email-g.liakhovetski@gmx.de>
 <7921225.sfO3PIeLVS@avalon>
 <Pine.LNX.4.64.1301251127460.17518@axis700.grange>
 <20130125182137.GB7393@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-sh-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Magnus Damm <magnus.damm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>,
 Laurent Pinchart <laurent.pinchart-ryLnwIuWjnjg/C1BVhZhaw@public.gmane.org>,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <20130125182137.GB7393-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hi Jason

Sorry for resuming an old thread, but I'd like to get this solved 
eventually.

On Fri, 25 Jan 2013, Jason Gunthorpe wrote:

> On Fri, Jan 25, 2013 at 11:34:55AM +0100, Guennadi Liakhovetski wrote:
> 
> > > Is there no need to reset the phy at runtime ?
> > 
> > No idea, I'm not developing the driver, I'm just porting one specific 
> > feature from one API to another with no functional changes (apart from 
> > postponing setting the GPIO).
> 
> Generally Linux relies on resetting the phy via the inband MDIO method,
> which is what Linux does. It is pretty much never required to reset
> via the hard pin - but you do need to generate a robust reset edge on
> the reset pin once after power up.

This all sounds good. So, is there a preferred way to do that? Where in 
the ethernet framework would you propose to hook up such a reset edge 
generation?

Thanks
Guennadi
---
Guennadi Liakhovetski, Ph.D.
Freelance Open-Source Software Developer
http://www.open-technology.de/
