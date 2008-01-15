From: Daniel Mack <daniel@caiaq.de>
Subject: Re: DM9000_IRQ_FLAGS
Date: Tue, 15 Jan 2008 12:42:27 +0100
Message-ID: <20080115114227.GA7868@buzzloop.caiaq.de>
References: <20071211191823.GD15295@buzzloop.caiaq.de> <3efb10970712111231r29f9fba1l3528d805d1009c52@mail.gmail.com> <20071212134153.GA21510@buzzloop.caiaq.de> <20071220094626.GB9216@fluff.org.uk> <3efb10970712200154u4c224071q6f5d5d7bb3bf0aa1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Dooks <ben@fluff.org>, netdev@vger.kernel.org
To: Remy Bohmer <linux@bohmer.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from buzzloop.caiaq.de ([212.112.241.133]:45446 "EHLO
	buzzloop.caiaq.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbYAOLmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 06:42:32 -0500
Content-Disposition: inline
In-Reply-To: <3efb10970712200154u4c224071q6f5d5d7bb3bf0aa1@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 20, 2007 at 10:54:34AM +0100, Remy Bohmer wrote:
> > I did have a go at trying to get people to pass the information this
> > way, but it seem to be ignored last time I sent it. I can dig out the
> > code that converts resource->flags to IRQT_ flags.
> 
> I thought this issue was already solved by using set_irq_type() in the
> BSP, just like all the other boards do...

Yes, exactly. I was trapped by another board file which specifies
interrupt types using 'struct resources'->flags for that
(arch/arm/mach-pxa/trizeps4.c) which is, as you pointed out earlier, not
the way to go. 

Sorry for the noise.

Best regards,
Daniel

