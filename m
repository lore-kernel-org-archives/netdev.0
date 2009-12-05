From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: RFC: how to control device specific features. sysfs or mod
 param?
Date: Sat, 05 Dec 2009 02:22:53 -0800
Message-ID: <1260008573.3565.17.camel@localhost>
References: <1260006955.3565.12.camel@localhost>
	 <20091205.021321.73648278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4950 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753113AbZLEKWs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2009 05:22:48 -0500
In-Reply-To: <20091205.021321.73648278.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-12-05 at 02:13 -0800, David Miller wrote:
> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Date: Sat, 05 Dec 2009 01:55:55 -0800
> 
> > My question is I want to toggle the underlying hardware mode to use one
> > or the other filter mechanism.  I can either do this using a module
> > parameter, which I'd like to avoid, or I can do this in a sysfs
> > parameter.  What do people think is the best approach?  Is there another
> > option I'm not considering here?
> 
> Other than sysfs another option to consider is trying to fit
> this into the ethtool framework somehow.

Yes, I looked at either ethtool or extending any of the existing
rtnetlink interfaces.  But my problem with those is this setting is very
specific to my hardware, and I'm not sure anyone else could benefit from
this.

I could try and make it as generic as possible, say pass a 32 or 64-bit
generic bitfield to a driver through an ethtool operation, and each
driver would apply some secret sauce based on the bitfield?

The sysfs option seems somewhat natural though.  It's part of the driver
itself, and would be a toggle switch for that specific driver.

I have no attachment to any of these options.  I just want whatever is
maintainable, makes sense, and if others can benefit, that's a great
bonus.

-PJ

