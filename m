From: David Brownell <david-b@pacbell.net>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function `usbnet_set_settings':
Date: Wed, 7 Nov 2007 18:53:48 -0800
Message-ID: <200711071853.48460.david-b@pacbell.net>
References: <200711012024.57412.toralf.foerster@gmx.de> <200711071434.52607.david-b@pacbell.net> <20071107225232.GB26163@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp120.sbc.mail.sp1.yahoo.com ([69.147.64.93]:37416 "HELO
	smtp120.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754123AbXKHCxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 21:53:51 -0500
In-Reply-To: <20071107225232.GB26163@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 07 November 2007, Adrian Bunk wrote:
> On Wed, Nov 07, 2007 at 02:34:52PM -0800, David Brownell wrote:
> > > > But on the other hand, it seems that only the ASIX code will work
> > > > right; the DM9601 and MCS7830 Kconfig is different/wrong.
> > > 
> > > I'm not seeing the problem.
> > > 
> > > Which configuration will be handled wrongly?
> > 
> > Notice how only the ASIX kconfig depended on NET_ETHERNET...
> > since MII depends on NET_ETHERNET, and (last I knew) the
> > reverse dependencies didn't capture the complete dependency
> > tree, selecting only MII would leave out some stuff.
> 
> Except for one s390 net driver (I'll check why it's doing this) the 
> NET_ETHERNET option does not influence what code is being generated - 
> it's just a Kconfig-internal option allowing to disable a huge bunch
> of drivers at once.

Drivers like ... AX88xxx, DM9601, and MCS7830!!  Except as
it turns out, only the first one behaves as intended.

You can tell it's a problem by the way it's inconsistent,
regardless of the details of the problem.  :)

- Dave
