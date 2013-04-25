From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] 3c509.c: call SET_NETDEV_DEV for all device types
 (ISA/ISAPnP/EISA)
Date: Thu, 25 Apr 2013 14:30:38 -0700
Message-ID: <20130425143038.5adb5078e7e6a69a10c43e69@linux-foundation.org>
References: <1366921743-6440-1-git-send-email-tedheadster@gmail.com>
	<51799A39.6070002@cogentembedded.com>
	<51799EFF.10003@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matthew Whitehead <tedheadster@gmail.com>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:57232 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758883Ab3DYVak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 17:30:40 -0400
In-Reply-To: <51799EFF.10003@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 26 Apr 2013 01:24:15 +0400 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com> wrote:

> Hello.
> 
> On 26-04-2013 1:03, Sergei Shtylyov wrote:
> 
> >> From: Matthew Whitehead <tedheadster@gmail.com>
> 
> >> The venerable 3c509 driver only sets its device parent in one case, the
> >> ISAPnP one.
> >> It does this with the SET_NETDEV_DEV function. It should register with the
> >> device
> >> hierarchy in two additional cases: standard (non-PnP) ISA and EISA.
> 
> >> - Currently they appear here:
> >> /sys/devices/virtual/net/eth0 (standard ISA)
> >> /sys/devices/virtual/net/eth1 (EISA)
> 
> >> - Rather, they should instead be here:
> >> /sys/devices/isa/3c509.0/net/eth0 (standard ISA)
> >> /sys/devices/pci0000:00/0000:00:07.0/00:04/net/eth1 (EISA)
> 
> >> Tested on ISA and EISA boards.
> 
> >     That's good but you forgot to sign off, so the patch can't be applied.
> 
> >     BTW, it seems that after almost 7 years I seem to have found a tester for
> > my patch which lingered all this time in the Andrew Morton's tree! You've said
> > you have EISA boards, how about testing my patch? Now if I could find Andrew
> > Morton's tree... Andrew?
> 
>     Found it at last at ozlabs.org but it turned out that Andrew has dropped 
> the patch without notifying me. :-(
> 

nah, you were asleep ;)

Message-Id: <200906101955.n5AJtMg7008475@imap1.linux-foundation.org>
Subject: [obsolete] 3x59x-fix-pci-resource-management.patch removed from -mm tree
To: sshtylyov@ru.mvista.com, mm-commits@vger.kernel.org
From: akpm@linux-foundation.org
Date:   Wed, 10 Jun 2009 12:55:21 -0700                                         
