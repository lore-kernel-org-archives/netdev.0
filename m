From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: RFC: how to control device specific features. sysfs or mod
 param?
Date: Sat, 05 Dec 2009 02:29:39 -0800
Message-ID: <1260008979.3565.25.camel@localhost>
References: <1260006955.3565.12.camel@localhost>
	 <20091205.021321.73648278.davem@davemloft.net>
	 <1260008573.3565.17.camel@localhost>
	 <20091205.022540.250826631.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62964 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753840AbZLEK3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2009 05:29:33 -0500
In-Reply-To: <20091205.022540.250826631.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-12-05 at 02:25 -0800, David Miller wrote:
> From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> Date: Sat, 05 Dec 2009 02:22:53 -0800
> 
> > Yes, I looked at either ethtool or extending any of the existing
> > rtnetlink interfaces.  But my problem with those is this setting is very
> > specific to my hardware, and I'm not sure anyone else could benefit from
> > this.
> > 
> > I could try and make it as generic as possible, say pass a 32 or 64-bit
> > generic bitfield to a driver through an ethtool operation, and each
> > driver would apply some secret sauce based on the bitfield?
> 
> We support device specific statistics in a nice way in ethtool, why
> don't we do something similar for device specific settings?
> 
> A variable length array of names (strings) and values.
> 
> This is pretty straightforward for what %99.9999 of uses will be,
> boolean enables.  If we make the value type a u32 we can handle pretty
> much all the other cases as well.

That does make sense.  I'll try and put something together to make this
work.

Thanks Dave,
-PJ

