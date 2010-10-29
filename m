From: David Lamparter <equinox@diac24.net>
Subject: Re: [PATCH 0/15] RFC: create drivers/net/legacy for ISA, EISA, MCA
 drivers
Date: Fri, 29 Oct 2010 11:40:51 +0200
Message-ID: <20101029094050.GA1835290@jupiter.n2.diac24.net>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
 <1288316896.1836.41.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:36453 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756687Ab0J2Jk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 05:40:59 -0400
Content-Disposition: inline
In-Reply-To: <1288316896.1836.41.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 28, 2010 at 06:48:16PM -0700, Joe Perches wrote:
> On Thu, 2010-10-28 at 21:19 -0400, Paul Gortmaker wrote:
> > The initial target is things like ISA/EISA/MCA drivers, and with
> > that alone, we can get close to 90 files out of drivers/net.
> > Plus, by having a semi-defined description for legacy as being
> > "drivers more than 10 years old" we'll always have a destination
> > for drivers as they fall out of maintainership and use.
> 
> I think legacy is "old and not sold or used much anymore".
> 
> I believe you're not moving 3c59x as that's relatively
> still popular even though it's nearly 15 years old.
> 
> Or maybe that was just an oversight...

The 3c59x driver also drives a few not-that-old 100MBit cards like
"3Com Corporation 3c905B 100BaseTX [Cyclone] [10b7:9055] (rev 64)"
and these are quite common still :)


-David

