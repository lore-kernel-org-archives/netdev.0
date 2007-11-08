From: Adrian Bunk <bunk@kernel.org>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function
	`usbnet_set_settings':
Date: Thu, 8 Nov 2007 04:23:08 +0100
Message-ID: <20071108032308.GE26163@stusta.de>
References: <200711012024.57412.toralf.foerster@gmx.de> <200711071434.52607.david-b@pacbell.net> <20071107225232.GB26163@stusta.de> <200711071853.48460.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: David Brownell <david-b@pacbell.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760630AbXKHDXo@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200711071853.48460.david-b@pacbell.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 07, 2007 at 06:53:48PM -0800, David Brownell wrote:
> On Wednesday 07 November 2007, Adrian Bunk wrote:
> > On Wed, Nov 07, 2007 at 02:34:52PM -0800, David Brownell wrote:
> > > > > But on the other hand, it seems that only the ASIX code will work
> > > > > right; the DM9601 and MCS7830 Kconfig is different/wrong.
> > > > 
> > > > I'm not seeing the problem.
> > > > 
> > > > Which configuration will be handled wrongly?
> > > 
> > > Notice how only the ASIX kconfig depended on NET_ETHERNET...
> > > since MII depends on NET_ETHERNET, and (last I knew) the
> > > reverse dependencies didn't capture the complete dependency
> > > tree, selecting only MII would leave out some stuff.
> > 
> > Except for one s390 net driver (I'll check why it's doing this) the 
> > NET_ETHERNET option does not influence what code is being generated - 
> > it's just a Kconfig-internal option allowing to disable a huge bunch
> > of drivers at once.
> 
> Drivers like ... AX88xxx, DM9601, and MCS7830!!  Except as
> it turns out, only the first one behaves as intended.
> 
> You can tell it's a problem by the way it's inconsistent,
> regardless of the details of the problem.  :)

I'm all for cleanups that make things consistent.  :)

As long as we can agree that there's a difference between a problem like 
a compile or runtime error and an opportunity for making things 
consistent.

> - Dave

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
