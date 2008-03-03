From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] New driver "sfc" for Solarstorm SFC4000 controller
 (try #7)
Date: Mon, 03 Mar 2008 13:29:41 -0800 (PST)
Message-ID: <20080303.132941.176565936.davem@davemloft.net>
References: <1204572175.16248.5.camel@localhost.localdomain>
	<20080303123937.2d72d7e8@extreme>
	<20080303211743.GG2988@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dcbw@redhat.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32999
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751151AbYCCV35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 16:29:57 -0500
In-Reply-To: <20080303211743.GG2988@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 3 Mar 2008 21:17:44 +0000

> It's not a simple device.  There are callbacks into MAC-, PHY- and
> board-specific code because this code supports several of each.  I
> spent some weeks ruthlessly paring away unnecessary abstraction and
> cruft, and I don't believe there is a significant amount left.

That is your opinion.

We have drivers that handle 30 or so variants of a particular
ethernet chipset and they are not nearly so huge as this
driver, and some of those cases don't have firmware either.

The driver needs to be reviewed on at least some level, but nobody is
going to walk through a 700K driver.  And I do mean nobody.

You have to find a way to trim this driver down and make it
more reviewable.

If I can write a full 10Gbit driver in ~11,000 lines of code
(~200,000 bytes), so can anyone else.
