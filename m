From: Donald Becker <becker@scyld.com>
Subject: Re: [ANNOUNCE] NAPI patches for 2.4.19-rc1
Date: Thu, 11 Jul 2002 14:53:55 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0207111450010.2498-100000@beohost.scyld.com>
References: <3D2DBDA4.4090009@candelatech.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, jamal <hadi@cyberus.ca>,
   <netdev@oss.sgi.com>
Return-path: <owner-netdev@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <3D2DBDA4.4090009@candelatech.com>
List-Id: netdev.vger.kernel.org

On Thu, 11 Jul 2002, Ben Greear wrote:

> > Very, very few vendor patchs are worth applying.  They sometimes know of
> > otherwise undocumented chip bugs, but a lot of the actual code is bad.
> > 
> > It's not "maintaining" a driver when you just take a vendor modification
> > of a driver and assume it's OK.  You have to understand the changes and
> > evaluate if they make sense.
> 
> I don't know the quality of the patches submitted by dlink, but I do
> know that the existing driver in the 2.4.18 kernel absolutely does not
> work at all.

It's a driver that _did_ work, but untested changes were made.

> So, if there is a hack/patch that makes it work, I consider
> that better than completely broken, even if it is ugly.

The DLink modified driver is still missing a few important changes for the
new chip version in MMIO mode.  For instance, ASICCtrl apparently must
now be read and written as a 32 bit word, while the older chip worked
with writew().

-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Second Generation Beowulf Clusters
Annapolis MD 21403			410-990-9993
