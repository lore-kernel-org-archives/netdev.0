From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] sky2: Fix recent WOL regression
Date: Thu, 9 Oct 2008 00:55:55 +0200
Message-ID: <200810090055.56598.rjw@sisk.pl>
References: <200810022339.34025.rjw@sisk.pl> <20081003090243.724cf79c@speedy>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	Tino Keitel <tino.keitel@gmx.de>, netdev@vger.kernel.org,
	Jesse Barnes <jbarnes@virtuousgeek.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:40763 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755744AbYJHWvl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 18:51:41 -0400
In-Reply-To: <20081003090243.724cf79c@speedy>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, 3 of October 2008, Stephen Hemminger wrote:
> On Thu, 2 Oct 2008 23:39:33 +0200
> "Rafael J. Wysocki" <rjw@sisk.pl> wrote:
> 
> > From: Rafael J. Wysocki <rjw@sisk.pl>
> > 
> > sky2: Fix recent WOL regression
> > 
> > Since dev->power.should_wakeup bit is used by the PCI core to
> > decide whether the device should wake up the system from sleep
> > states, set/unset this bit whenever WOL is enabled/disabled using
> > sky2_set_wol() (this fixes a regression from 2.6.26 on the Tino's
> > machine).
> > 
> > Remove an open-coded reference to the standard PCI PM registers that
> > is not used any more.
> > 
> > Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
> > Reported-by: Tino Keitel <tino.keitel@gmx.de>
> > ---
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Thanks for fixing this.

Can you please include this patch into your next push for Jeff?

It seems to have been overlooked.

Thanks,
Rafael
