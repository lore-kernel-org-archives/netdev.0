From: Donald Becker <becker@scyld.com>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Thu, 11 Jul 2002 12:50:56 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0207111238570.2498-100000@beohost.scyld.com>
References: <3D2D9CC8.5050200@mandrakesoft.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jamal <hadi@cyberus.ca>, <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Jeff Garzik <jgarzik@mandrakesoft.com>
In-Reply-To: <3D2D9CC8.5050200@mandrakesoft.com>
List-Id: netdev.vger.kernel.org

On Thu, 11 Jul 2002, Jeff Garzik wrote:
> Donald Becker wrote:
> > The mdelay(300) is completely bogus.
...
> Ouch.  You are absolutely right, and I take the blame for not reviewing 
> more closely.  That's what I get for trusting vendors too much ;-)
> [D-Link has been the one patching sundance and dl2k for a while now]

Very, very few vendor patchs are worth applying.  They sometimes know of
otherwise undocumented chip bugs, but a lot of the actual code is bad.

It's not "maintaining" a driver when you just take a vendor modification
of a driver and assume it's OK.  You have to understand the changes and
evaluate if they make sense.

> I've been meaning to go through several drivers and fix up the stupid 
> assumptions they make about autonegotiation completion time.

Putting broken changes into the kernel with a plan to go back later and
clean them is a bad development methodology.

> > The driver also changes the transceiver settings to non-standard
> > values.
> Which lines of code are you referring to?

Removing "options" as a way to set the transceiver.

> This _might_ be a case where the docs are inaccurate, since the patch 
> was done by D-Link with access to the chip designers.

No, it's unrelated to specific chip.  It's a change that looks good when
you see only that driver, but the change makes it inconsistent will all
of the other drivers.  

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
