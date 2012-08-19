From: Shaun Ruffell <sruffell@digium.com>
Subject: Re: BUG: unable to handle kernel paging request at 00010016
Date: Sun, 19 Aug 2012 12:19:50 -0500
Message-ID: <20120819171950.GB14461@digium.com>
References: <502ECC74.9030605@oak.selfip.net>
 <20120819042543.GA14461@digium.com>
 <20120819082117.GA4634@thinkpad.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Haywood <tla@oak.selfip.net>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Artem Savkov <artem.savkov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120819082117.GA4634@thinkpad.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ Fixing netdev cc to use proper dadress... ]

On Sun, Aug 19, 2012 at 12:21:17PM +0400, Artem Savkov wrote:
> On Sat, Aug 18, 2012 at 11:25:43PM -0500, Shaun Ruffell wrote:
> > Adding linux-net to the CC list.
> > 
> > On Fri, Aug 17, 2012 at 11:57:56PM +0100, Dave Haywood wrote:
> > > [1.] One line summary of the problem:
> > > BUG: unable to handle kernel paging request at 00010016
> > > 
> > > 	System boots then crashes a 5-10 or so seconds after getting to the login prompt
> > > 	Booting without the network cable attached prevents the crash (no evidence beyond 10 minutes after boot)
> > > 
> > >   Diagnostics:
> > > 	Captured the boot and managed a login + dmesg before the crash
> > > 	Some of the log looks corrupted. Probably my crappy usb dongle serial flow control but left it in anyway
> > 
> > [snip]
> > 
> > Just a note that I see this as well. It happens reliably for me after trying to
> > login to the machine via ssh.
> > 
> > Here is the back trace I collected on the serial port.
>
> There is a patch posted on netdev that fixes this for me:
> http://patchwork.ozlabs.org/patch/178525/

Thanks, I just applied that patch and confirmed that it does indeed
resolve the crash for me as well.

Cheers,
Shaun
