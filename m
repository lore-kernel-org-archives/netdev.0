From: Mika Westerberg <mika.westerberg@iki.fi>
Subject: Re: [PATCH v2 1/5] ep93xx: set DMA masks for the ep93xx_eth
Date: Thu, 9 Jun 2011 22:50:52 +0300
Message-ID: <20110609195052.GB2857@acer>
References: <f20d8fe52f823e7e65423720c53f2935d3e08967.1307040443.git.mika.westerberg@iki.fi>
 <20110605083445.GT16318@ibawizard.net>
 <20110605085948.GB16018@acer>
 <20110605.140801.1144137337172959622.davem@davemloft.net>
 <20110606172607.GB3082@acer>
 <ADE657CA350FB648AAC2C43247A983F001F381FC56CE@AUSP01VMBX24.collaborationhost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"ynezz@true.cz" <ynezz@true.cz>, rmallon@gmail.com,
	florian@openwrt.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"kernel@wantstofly.org" <kernel@wantstofly.org>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:63845 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754692Ab1FITxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 15:53:19 -0400
Received: by eyx24 with SMTP id 24so664991eyx.19
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2011 12:53:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <ADE657CA350FB648AAC2C43247A983F001F381FC56CE@AUSP01VMBX24.collaborationhost.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(corrected Ryan's email address, added Florian Fainelli)

On Mon, Jun 06, 2011 at 12:48:19PM -0500, H Hartley Sweeten wrote:
> On Monday, June 06, 2011 10:26 AM, Mika Westerberg wrote:
> > On Sun, Jun 05, 2011 at 02:08:01PM -0700, David Miller wrote:
> >> From: Mika Westerberg <mika.westerberg@iki.fi>
> >> Date: Sun, 5 Jun 2011 11:59:48 +0300
> >> 
> >>> It looks like David Miller (CC'd) has been taking care of ep93xx_eth.c maybe
> >>> he knows this better.
> >> 
> >> Someone needs to step up and take over as the real maintainer of this
> >> driver.  The way the driver is currently being hacked on is
> >> unsustainable.
> >
> > Can't agree more.
> >
> > Hartley, Ryan: do you have any preferences? Are you guys already overwhelmed
> > with your current maintenance work, or could you consider taking this one as
> > well? 
> >
> > If no one else steps up, I can volunteer but I have to admit that I don't know
> > much about that driver.
> 
> I feel the same way.
> 
> If Lennert is no longer maintaining the this driver we really need someone to
> step up and handle it.
> 
> I have no problem doing it but I really don't have a good grasp on the driver
> or the whole network subsystem.
> 
> If Lennert is willing to hand it over, I have no problem being listed as a
> co-maintainer along with either yourself of Ryan.  Between the two (or three)
> of us we should be able to handle it.

Hartley,

Can you take maintainership of this driver? Since you already maintain most of
the ep93xx core stuff I think that you are the right person for the job. If
you need any assistance I believe me and Ryan can help you out.

We have now few patches queued:
	- this series from me to fix the DMA API violations
	- phylib patches from Florian Fainelli

It would be great to get those in someday :-)
