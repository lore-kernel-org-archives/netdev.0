From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 5/5] [powerpc] Fix up fsl-flexcan device tree binding.
Date: Tue, 9 Aug 2011 15:59:00 -0500
Message-ID: <20110809205900.GC4926@sgi.com>
References: <1312901031-29887-1-git-send-email-holt@sgi.com>
 <1312901031-29887-6-git-send-email-holt@sgi.com>
 <4E4179CB.6030101@freescale.com>
 <20110809184524.GB4926@sgi.com>
 <4E4186BD.5000602@freescale.com>
 <4E418F2D.4060504@grandegger.com>
 <4E419180.3090507@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Grandegger <wg@grandegger.com>, Robin Holt <holt@sgi.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	U Bhaskar-B22300 <B22300@freescale.com>,
	netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	PPC list <linuxppc-dev@lists.ozlabs.org>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:52049 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807Ab1HIU7C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 16:59:02 -0400
Content-Disposition: inline
In-Reply-To: <4E419180.3090507@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I guess my poor wording may have gotten me in trouble.  I am getting
ready to repost this patch, but I want to ensure I am getting it as
right as possible.

I think I should reword the commit message to indicate we are removing
the Documentation/.../fsl-flexcan.txt file which has essentially become
empty and change the p1010si.dtsi file's can nodes to "fsl,p1010-flexcan",
"fsl,flexcan".  Is that correct?

Thanks,
Robin

On Tue, Aug 09, 2011 at 02:58:56PM -0500, Scott Wood wrote:
> On 08/09/2011 02:49 PM, Wolfgang Grandegger wrote:
> > Yes. The doc for the bindings we speak about
> > 
> > http://lxr.linux.no/#linux+v3.0.1/Documentation/devicetree/bindings/net/can/fsl-flexcan.txt
> > 
> > sneaked into the kernel without been presented on any mailing list and
> > without the corresponding driver patch.
> 
> It was posted on linuxppc-dev:
> http://patchwork.ozlabs.org/patch/91980/
> 
> Though I agree it should have been posted more widely.
> 
> > OK, just
> > 
> >   "fsl,p1010-flexcan"
> > 
> > or
> > 
> >   "fsl,p1010-flexcan", "fsl,flexcan"
> 
> I'm ok with the latter, if there's enough in common that it's
> conceivable that a driver wouldn't care.  The more specific compatible
> will be there if the driver wants to make use of it later.
> 
> -Scot
