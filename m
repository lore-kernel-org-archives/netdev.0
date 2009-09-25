From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] 3c59x: Get rid of "Trying to free already-free IRQ"
Date: Fri, 25 Sep 2009 14:35:24 +0200
Message-ID: <200909251435.24942.rjw@sisk.pl>
References: <20090924183152.GA30254@oksana.dev.rtsoft.ru> <20090924213039.GA15904@oksana.dev.rtsoft.ru> <20090924.152619.260814858.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: avorontsov@ru.mvista.com, linux-pm@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:52102 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752374AbZIYMeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 08:34:01 -0400
In-Reply-To: <20090924.152619.260814858.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 25 September 2009, David Miller wrote:
> From: Anton Vorontsov <avorontsov@ru.mvista.com>
> Date: Fri, 25 Sep 2009 01:30:39 +0400
> 
> > On Thu, Sep 24, 2009 at 10:30:33PM +0200, Rafael J. Wysocki wrote:
> >> On Thursday 24 September 2009, Anton Vorontsov wrote:
> >> > Following trace pops up if we try to suspend with 3c59x ethernet NIC
> >> > brought down:
> >> 
> >> Patch looks good, but IMO it'd be a little effort to convert the driver to
> >> dev_pm_ops while you're at it (please see r8169 for a working example).
> > 
> > I'd like to avoid putting irrelevant stuff into bugfixes.
> 
> Agreed.

Well, the point is that all of the PCI core stuff the driver does is not
necessary and should better be dropped along with the IRQ thing.

Best,
Rafael
