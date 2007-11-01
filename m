From: Adrian Bunk <bunk@kernel.org>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function
	`usbnet_set_settings':
Date: Fri, 2 Nov 2007 00:44:43 +0100
Message-ID: <20071101234443.GD7227@stusta.de>
References: <200711012024.57412.toralf.foerster@gmx.de> <20071101141124.0cbe2897.randy.dunlap@oracle.com> <200711011632.18333.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:46456 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752876AbXKAXpD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 19:45:03 -0400
Content-Disposition: inline
In-Reply-To: <200711011632.18333.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 01, 2007 at 04:32:18PM -0700, David Brownell wrote:
> On Thursday 01 November 2007, Randy Dunlap wrote:
> > The MII functions aren't available unless NET_ETHERNET=y.

The setting of CONFIG_NET_ETHERNET doesn't matter for this bug.

> > Howver, the MII functions aren't always needed...
> > 
> > David, any ideas on this one?
> 
> It's been several years since I looked at this.  It
> used to behave just fine.
> 
> Something must have changed in the not-too-distant
> past to have broken this mechanism...
>...

It seems to be an old bug.

The following combination of options is simply an unusual one:

CONFIG_MII=m
CONFIG_USB_USBNET=y
CONFIG_USB_USBNET_MII=n

> - Dave

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

