From: Stefan Rompf <srompf@isg.de>
Subject: Re: [ANNOUNCE] netplug, a daemon that handles network cables getting plugged in and out
Date: Wed, 3 Sep 2003 10:42:35 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200309031042.54413.srompf@isg.de>
References: <1062105712.12285.78.camel@serpentine.internal.keyresearch.com> <3F4E8373.1040204@pobox.com> <20030828224553.GC23528@werewolf.able.es>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <20030828224553.GC23528@werewolf.able.es>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Hi,

> That would be very nice, but there is still a problem.
> Does netlink solve the fact that there are cards (at least in 2.4)
> that do not support any detection method:

even in 2.6 not all cards support link state via netlink, it requires some 
updates to the driver. Maintainers should take this as a hint to add 
netif_carrier_on()/_off() or mii_check_link()/mii_check_media()-calls ;-).

This does not hurt for 2.4 as these functions are already available there, but 
do not create notifications in the stock kernel.

Stefan
-- 
"doesn't work" is not a magic word to explain everything.
