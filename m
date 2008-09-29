From: Tino Keitel <tino.keitel@gmx.de>
Subject: Re: Regression in 2.6.27-rc7: Wake On LAN with sky2 broken
Date: Mon, 29 Sep 2008 23:18:03 +0200
Message-ID: <20080929211803.GA3185@dose.home.local>
References: <20080924080546.GA21108@x61> <20080925194253.GA2783@dose.home.local> <20080925200311.GA4582@dose.home.local> <200809252238.01656.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:51308 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991AbYI2VQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 17:16:59 -0400
Content-Disposition: inline
In-Reply-To: <200809252238.01656.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 25, 2008 at 22:38:01 +0200, Rafael J. Wysocki wrote:
> On Thursday, 25 of September 2008, Tino Keitel wrote:
> > Hi,
> > 
> > I just found a method how I can enable WOL again:
> > 
> > echo enabled >
> > /sys/devices/pci0000:00/0000:00:1c.0/0000:01:00.0/power/wakeup
> > 
> > This device is the NIC device, of cause.
> 
> I guess the box didn't hang during suspend with this setting?
> 
> If that's correct, please test the patch below.

With the attached patch, WOL works as intended the hang also didn't
happen.

Thanks and regards,
Tino
