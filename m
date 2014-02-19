From: Laurent Pinchart <laurent.pinchart@ideasonboard.com>
Subject: Re: [PATCH] net: add init-regs for of_phy support
Date: Wed, 19 Feb 2014 18:15:03 +0100
Message-ID: <19899452.nJCbJf89OP@avalon>
References: <1392642484-19938-1-git-send-email-ben.dooks@codethink.co.uk> <530213A4.4030400@codethink.co.uk> <20140217141222.GB19308@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-sh@vger.kernel.org" <linux-sh@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perceval.ideasonboard.com ([95.142.166.194]:50293 "EHLO
	perceval.ideasonboard.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753968AbaBSRNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 12:13:53 -0500
In-Reply-To: <20140217141222.GB19308@e106331-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Monday 17 February 2014 14:12:22 Mark Rutland wrote:
> On Mon, Feb 17, 2014 at 01:50:28PM +0000, Ben Dooks wrote:
> > On 17/02/14 13:44, Mark Rutland wrote:
> > > On Mon, Feb 17, 2014 at 01:08:04PM +0000, Ben Dooks wrote:
> > >> Add new init-regs field for of_phy nodes and make sure these
> > >> get applied when the phy is configured.
> > >> 
> > >> This allows any phy node in an fdt to initialise registers
> > >> that may not be set as standard by the driver at initialisation
> > >> time, such as LED controls.
> > > 
> > > Why not have a driver for the particular PHY? If it's not standard we
> > > don't need to pretend it is. If it has some extensions then the standard
> > > compatible string can be a fallback entry in the compatible list.
> > 
> > I was trying to provide some useful and reasonably generic code
> > to setup PHYs without having to add specific arguments to each of
> > them.
> > 
> > I could have added something like ksz8041,led-mode1 = <1> and
> > updated the micrel driver.
> 
> Perhaps. It depends on precisely what the property is describing.
> 
> I think describing the hardware and letting Linux figure out what to do
> is better than giving it a set of opaque instructions for it to blindly
> follow.

I second that, I think a LED mode property would be better in this case.

-- 
Regards,

Laurent Pinchart
