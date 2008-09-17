From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: atl1: WARNING at net/sched/sch_generic.c:221
Date: Wed, 17 Sep 2008 11:44:46 +0400
Message-ID: <20080917074446.GB3770@x200.localdomain>
References: <20080821115849.GA2126@x200.localdomain> <20080914181714.34935d9c@osprey.hogchain.net> <20080915224522.GA21012@x200.localdomain> <20080915204431.45201beb@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.187]:38031 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750879AbYIQHmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2008 03:42:43 -0400
Received: by gv-out-0910.google.com with SMTP id e6so1506661gvc.37
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2008 00:42:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080915204431.45201beb@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 08:44:31PM -0500, Jay Cliburn wrote:
> On Tue, 16 Sep 2008 02:45:22 +0400
> Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> > On Sun, Sep 14, 2008 at 06:17:14PM -0500, Jay Cliburn wrote:
> > > On Thu, 21 Aug 2008 15:58:49 +0400
> > > adobriyan@gmail.com wrote:
> > > 
> > > > This message happens more or less every reboot, sometimes cable
> > > > unplug/plug is needed to restore connectivity, otherwise card is
> > > > working fine.
> > > > 
> > > > 
> > > > [   22.570010] eth1: link up, 100Mbps, full-duplex, lpa 0x45E1
> > > > [   26.570011] NET: Registered protocol family 10
> > > > [   37.551934] eth0: no IPv6 routers present
> > > > 
> > > > 	[rebooted box which is directly connected to a box with
> > > > atl1]
> > > > 
> > > > [ 2078.740004] atl1 0000:03:00.0: eth0 link is down
> > > > [ 2080.790004] atl1 0000:03:00.0: eth0 link is up 1000 Mbps full
> > > > duplex [ 2086.049998] NETDEV WATCHDOG: eth0 (atl1): transmit
> > > > timed out [ 2086.050004] ------------[ cut here ]------------
> > > > [ 2086.050004] WARNING: at net/sched/sch_generic.c:221
> > > [...]
> > > 
> > > Alexey,
> > > 
> > > Can you please try this patch?
> > 
> > Seems to help (no more messages), still sometimes no networking until
> > after cable replug. Stay tuned.
> 
> Does this stay tuned mean, "Jay, hold off while I (Alexey) troubleshoot
> this further."  Or does it mean, "Jay, you've not completely solved the
> problem yet and you need to continue working on it."

I don't know.

Transmit timeout messages definitely dissapeared, no network until cable
replug a) happened earlier, b) much more rare than transmit timeouts.

> If it's the latter, can you please describe your setup and how you reproduce
> the problem?  Is the box you have connected directly to the atl1 box used
> as a netconsole?

atl1 netconsoles to r8169, connected directly without any switches.

It usually happens after one of the boxes reboots (well, obviously)
