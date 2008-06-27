From: <Mario_Limonciello@Dell.com>
Subject: RE: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset in Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another Problem)
Date: Thu, 26 Jun 2008 22:25:04 -0500
Message-ID: <E6FF208A16840D4EBAA31D261B15A506011CAF92@ausx3mpc121.aus.amer.dell.com>
References: <4861800B.90703@nscus.com> <20080625213142.GA29890@electric-eye.fr.zoreil.com> <48640535.2050000@nscus.com> <20080626215918.GC2555@electric-eye.fr.zoreil.com> <20080627023523.GD7703@parisc-linux.org> <006001c8d801$b02daf10$860aa8c0@MICHAEL1>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <lkml@metanurb.dk>,
	<akpm@linux-foundation.org>, <linux-pci@vger.kernel.org>
To: <mgrollman@nscus.com>, <matthew@wil.cx>, <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:21796 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbYF0DZ5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2008 23:25:57 -0400
Content-class: urn:content-classes:message
In-Reply-To: <006001c8d801$b02daf10$860aa8c0@MICHAEL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is *not* just specific to your hardware.  I've encountered it on
two other platforms that have RTL8102's.  I posted some comments in
another thread the other day.

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of mgrollman@nscus.com
Sent: Thursday, June 26, 2008 9:58 PM
To: 'Matthew Wilcox'; 'Francois Romieu'
Cc: netdev@vger.kernel.org; 'Kasper Sandberg';
akpm@linux-foundation.org; linux-pci@vger.kernel.org
Subject: RE: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset
in Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash,
Another Problem)

Matthew,

The only remedy I have found to date is a system reboot, sometimes a
soft
one will work, sometimes a full
power down is needed.  It may take a few boots to get it happy.  If I
can
get it to boot with the Realtek working OK, the system does not seem to
fail, even after hours of use.  So either it comes up working, or it
does
not.

But I am open to any ideas to try and correct!  I have an extra
motherboard
around, if you guys think it may be in this particular unit's hardware.

- Michael


-----Original Message-----
From: Matthew Wilcox [mailto:matthew@wil.cx] 
Sent: Thursday, June 26, 2008 7:35 PM
To: Francois Romieu
Cc: Michael Grollman; netdev@vger.kernel.org; Kasper Sandberg;
akpm@linux-foundation.org; linux-pci@vger.kernel.org
Subject: Re: 8169 Intermittent ifup Failure Issue With RTL8102E Chipset
in
Intel's New D945GCLF Atom Board (Not the Initial Modprobe Crash, Another
Problem)

On Thu, Jun 26, 2008 at 11:59:18PM +0200, Francois Romieu wrote:
> (linux-pci Cced)
> 
> Michael Grollman <mgrollman@nscus.com> :
> [...]
> > Per instructions, I built an 2.6.26-rc8 system on the target Intel 
> > hardware, and was able to re-recreate the intermittent failure of
the
8201.
> >  When in failure mode, the lspci -vx' display of the pci registers 
> > of the
> > 8102 is as follows:
> >
> > 01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. 
> > RTL8101E PCI Express Fast Ethernet controller (rev ff) (prog-if ff)
> >    !!! Unknown header type 7f
> > 00: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> > 10: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> > 20: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff
> > 30: ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff ff

Mmm.  All f's means that the device has fallen off the bus.  Nothing is
responding when we ask the device about it's config space.  What do you
do
to get this device into this state?

--
Intel are signing my paycheques ... these opinions are still mine "Bill,
look, we understand that you're interested in selling us this operating
system, but compare it to ours.  We can't possibly take such a
retrograde
step."

--
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
