From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [linux-pm] WOL with flex filters, reflecting it in /sys
Date: Thu, 1 Oct 2009 23:23:15 +0200
Message-ID: <200910012323.15166.rjw@sisk.pl>
References: <76FA3B279DD9DA48896E2B404944957203C09587@USA7061MS02.na.xerox.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Leisner, Martin" <Martin.Leisner@xerox.com>,
	netdev@vger.kernel.org, martyleisner@yahoo.com
To: linux-pm@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:56796 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097AbZJAVWD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 17:22:03 -0400
In-Reply-To: <76FA3B279DD9DA48896E2B404944957203C09587@USA7061MS02.na.xerox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 01 October 2009, Leisner, Martin wrote:
> I'm looking to extend the work of Mitch Williams to support flexible
> filters.
> (http://www.mail-archive.com/netdev@vger.kernel.org/msg60332.html}
> 
> Looking at the problem, would it be a good idea to reflect WOL
> characteristics in the /sys filesystem (instead of requiring ethtool to
> set them)?
> 
> Seems straightforward and easy enough.

I'm not sure about that.

The supported WoL settings seem to depend on the driver and whether WoL is
going to work also depends on the device's power/wakeup setting.

Thanks,
Rafael
