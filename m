From: David Miller <davem@davemloft.net>
Subject: Re: RFC: how to control device specific features. sysfs or mod
 param?
Date: Sat, 05 Dec 2009 02:25:40 -0800 (PST)
Message-ID: <20091205.022540.250826631.davem@davemloft.net>
References: <1260006955.3565.12.camel@localhost>
	<20091205.021321.73648278.davem@davemloft.net>
	<1260008573.3565.17.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43268
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752177AbZLEKZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2009 05:25:33 -0500
In-Reply-To: <1260008573.3565.17.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Sat, 05 Dec 2009 02:22:53 -0800

> Yes, I looked at either ethtool or extending any of the existing
> rtnetlink interfaces.  But my problem with those is this setting is very
> specific to my hardware, and I'm not sure anyone else could benefit from
> this.
> 
> I could try and make it as generic as possible, say pass a 32 or 64-bit
> generic bitfield to a driver through an ethtool operation, and each
> driver would apply some secret sauce based on the bitfield?

We support device specific statistics in a nice way in ethtool, why
don't we do something similar for device specific settings?

A variable length array of names (strings) and values.

This is pretty straightforward for what %99.9999 of uses will be,
boolean enables.  If we make the value type a u32 we can handle pretty
much all the other cases as well.
