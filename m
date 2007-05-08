From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Intel IXP4xx network drivers v.3 - QMGR
Date: Tue, 8 May 2007 14:59:21 +0200
Message-ID: <20070508125921.GA32669@xi.wantstofly.org>
References: <m3abwhcy74.fsf@maximus.localdomain> <m3vef5biob.fsf@maximus.localdomain> <5BB7E1AB-5CE1-43C8-8CE3-E0DE0236BD09@cam.ac.uk> <m3hcqoa772.fsf@maximus.localdomain> <86D26EBE-5899-468F-9C79-23E83E0DE04B@cam.ac.uk> <m33b289zku.fsf@maximus.localdomain> <m31whs5ehn.fsf_-_@maximus.localdomain> <20070508113232.GA32055@xi.wantstofly.org> <f19298770705080547m3c0b5583qd6ad7aaca816361c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Michael-Luke Jones <mlj28@cam.ac.uk>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>,
	Russell King <rmk@arm.linux.org.uk>,
	ARM Linux Mailing List
	<linux-arm-kernel@lists.arm.linux.org.uk>
To: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:50080 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934528AbXEHM7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 08:59:24 -0400
Content-Disposition: inline
In-Reply-To: <f19298770705080547m3c0b5583qd6ad7aaca816361c@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 04:47:31PM +0400, Alexey Zaytsev wrote:

> > As with Christian's driver, I don't know whether an SRAM allocator
> > makes much sense.  We can just set up a static allocation map for the
> > in-tree drivers and leave out the allocator altogether.  I.e. I don't
> > think it's worth the complexity (and just because the butt-ugly Intel
> > code has an allocator isn't a very good reason. :-)
> 
> Is the qmgr used when the NPEs are utilized as DMA engines?

I'm not sure, but probably yes.


> And is the allocator needed in this case?

If you statically partition the available queue SRAM, no.
