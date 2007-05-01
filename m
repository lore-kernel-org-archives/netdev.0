From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] libertas: fix for wireless Kconfig changes
Date: Tue, 1 May 2007 09:54:54 -0400
Message-ID: <20070501135454.GD8604@tuxdriver.com>
References: <20070429002844.GA11225@tuxdriver.com> <1178020418.21671.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2534 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423574AbXEAOWS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 10:22:18 -0400
Content-Disposition: inline
In-Reply-To: <1178020418.21671.3.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 01, 2007 at 07:53:38AM -0400, Dan Williams wrote:
> On Sat, 2007-04-28 at 20:28 -0400, John W. Linville wrote:
> > Need to change the libertas Kconfig entry to match changes made for
> > other wireless drivers.
> > 
> > Signed-off-by: John W. Linville <linville@tuxdriver.com>
> > ---
> > diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
> > index c4b3dc2..cb09e6b 100644
> > --- a/drivers/net/wireless/Kconfig
> > +++ b/drivers/net/wireless/Kconfig
> > @@ -267,7 +267,7 @@ config IPW2200_DEBUG
> >  
> >  config LIBERTAS_USB
> >  	tristate "Marvell Libertas 8388 802.11a/b/g cards"
> > -	depends on NET_RADIO && USB
> > +	depends on USB && WLAN_80211
> >  	select FW_LOADER
> >  	---help---
> >  	  A driver for Marvell Libertas 8388 USB devices.
> 
> Will apply, we need to pull in wireless-dev first to get the NET_RADIO
> name change.

No, that is already in Linus' tree via Jeff's tree.

Jeff, I figured you would just apply the patch.  If you'd prefer I
can send a pull request, but I don't have anything else pending ATM.

John
-- 
John W. Linville
linville@tuxdriver.com
