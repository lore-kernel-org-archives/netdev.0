From: Donald Becker <becker@scyld.com>
Subject: Re: pci-skeleton duplex check
Date: Thu, 12 Dec 2002 16:11:13 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0212121539110.10674-100000@beohost.scyld.com>
References: <3DF8F26E.50306@pobox.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Roger Luethi <rl@hellgate.ch>, <netdev@oss.sgi.com>,
   Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3DF8F26E.50306@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 12 Dec 2002, Jeff Garzik wrote:
> Donald Becker wrote:
> > [[ I don't know why I bother. The people that now control what goes into
> > the kernel would rather put in random patches from other people than
> > accept a correct fix from me. ]]
> 
> I'm very interested in applying fixes from you!  I am publicly begging 
> you to do so, and even CC'ing lkml on my request.

This is very disingenuous statement.

The drivers in the kernel are now heavily modified and have significantly
diverged from my version.  Sure, you are fine with having someone else
do the difficult and unrewarding debugging and maintainence work, while
you work on just the latest cool hardware, change the interfaces and are
concerned only with the current kernel version.

I've been actively developing Linux drivers for over a decade, and run
about two dozen mailing lists for specific drivers.  I write diagnostic
routines for every released driver.  I thoroughly test and frequently
update the driver set I maintain.  And since about 2000, my patches were
ignored while the first notice I've have gotten to changes in my drivers
is the bug reports.  And the response: "submit a patch to fix those
newly introduced bugs".  I've even had patches ignore in favor of people
that wrote "I don't have the NIC, but here is a change".

A good example is the tulip driver.  You repeatedly restructured my
driver in the kernel, splitting into different files.  It was still 90+%
my code, but the changes made it impossible to track the modification
history.  The kernel driver was long-broken with 21143-SYM cards, but no
one took the responsibility for fixing it.


It's easy to make the first few patches, when you don't have to deal
with reversion testing, many different models, and have an unlimited
sandbox where it doesn't matter if a specific release works or not.  But
it takes a huge of work to keep a stable, tracable driver development
process that works with many different kernel versions and hardware
environments.


-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
