From: Bill Fink <billfink@mindspring.com>
Subject: Re: Realtek RTL8111B serious performance issues
Date: Thu, 19 Jul 2007 00:44:29 -0400
Message-ID: <20070719004429.fc33c8a7.billfink@mindspring.com>
References: <Pine.SOC.4.64.0707172328150.3299@katana>
	<20070718072635.GA26243@electric-eye.fr.zoreil.com>
	<Pine.SOC.4.64.0707181516300.19789@katana>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: john@BlueSkyTours.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-scoter.atl.sa.earthlink.net ([209.86.89.67]:34764 "EHLO
	elasmtp-scoter.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751041AbXGSEos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 00:44:48 -0400
In-Reply-To: <Pine.SOC.4.64.0707181516300.19789@katana>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi John,

On Wed, 18 Jul 2007, john@BlueSkyTours.com wrote:

> On Wed, 18 Jul 2007, Francois Romieu wrote:
> 
> > john@BlueSkyTours.com <john@BlueSkyTours.com> :
> > [...]
> >> Anyone have any suggestions for solving this problem?
> >
> > Try 2.6.23-rc1 when it is published or apply against 2.6.22 one of:
> > http://www.fr.zoreil.com/people/francois/misc/20070628-2.6.22-rc6-r8169-test.patch
> 
> Unfortunately, the 20070628 patch did not make any difference.
> 
> 
> > http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.22-rc6/r8169-20070628/
> 
> 
> I tried various patches from that directory (aren't most or all of them
> included in the 20070628 patch?), but none of them helped either.
> 
> 
> This problem could be very difficult to track down.  Like I said, it
> definately effects emacs and firefox being "drawn" on a remote computer.
> Ping times, however, are not that bad:
> 
> PING 192.168.26.150: 56 data bytes
> 64 bytes from dyn26-1.blueskytours.com (192.168.26.150): icmp_seq=0. time=0.287 ms
> 64 bytes from dyn26-1.blueskytours.com (192.168.26.150): icmp_seq=1. time=0.279 ms
> 64 bytes from dyn26-1.blueskytours.com (192.168.26.150): icmp_seq=2. time=0.196 ms
> 64 bytes from dyn26-1.blueskytours.com (192.168.26.150): icmp_seq=3. time=0.201 ms
> 64 bytes from dyn26-1.blueskytours.com (192.168.26.150): icmp_seq=4. time=0.159 ms
> 64 bytes from dyn26-1.blueskytours.com (192.168.26.150): icmp_seq=5. time=0.148 ms
> 64 bytes from dyn26-1.blueskytours.com (192.168.26.150): icmp_seq=6. time=0.150 ms
> 
> Also, wget gets good throughput when retrieving files.
> 
> It just seems to be X traffic which is extremely slow.  Using the old
> Linksys 10/100 PCI NIC, emacs comes up virtually instantaneously.  Using the
> integrated Realtek 8111B, emacs takes 10 seconds to draw.
> 
> Thank you very much for trying to help.

Any chance that the Realtek 8111B is sharing interrupts with another
device ("cat /proc/interrupts")?  Perhaps it is, and the Linksys isn't,
which could explain the difference in behavior.  Just something simple
to check and either rule in or out.

						-Bill
