From: maximilian attems <max@stro.at>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Sat, 5 Jul 2008 12:26:34 +0200
Message-ID: <20080705102633.GA21779@stro.at>
References: <1215111362.10393.651.camel@pmac.infradead.org> <20080703.162120.206258339.davem@davemloft.net> <486D6DDB.4010205@infradead.org> <87ej6armez.fsf@basil.nowhere.org> <1215177044.10393.743.camel@pmac.infradead.org> <486E2260.5050503@garzik.org> <1215178035.10393.763.camel@pmac.infradead.org> <20080704141014.GA23215@mit.edu> <20080704142403.GD7212@baikonur.stro.at> <20080704143634.GC23215@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Theodore Tso <tytso@mit.edu>,
	David Woodhouse <dwmw2@infradead.org>,
	Jeff Garzik <jeff@garzik.org>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hugh@veritas
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:57722 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750793AbYGEK0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jul 2008 06:26:41 -0400
Content-Disposition: inline
In-Reply-To: <20080704143634.GC23215@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 04 Jul 2008, Theodore Tso wrote:

> On Fri, Jul 04, 2008 at 04:24:03PM +0200, maximilian attems wrote:
> > yes i'd call them severly broken.
> > as it is quite easy to pick up the modinfo firmware module output.
> > 
> > their trouble is that they sync initramfs-tools from Debian only
> > once every 2 years or so.
> 
> Well, Takashi just mentioned that SuSE's mkinitrd may not handle
> /lib/firmware correctly either....

i have good news: in intrepid they synced initramfs-tools,
so it is fixed for their upcoming release. as it is fixed
in Debian for Lenny. they went for the /lib/firmware/${version}
choice.

-- 
maks
