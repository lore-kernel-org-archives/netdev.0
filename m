From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7502] New: sunhme not working with 2.6.18 on
 x86
Date: Sun, 12 Nov 2006 21:36:48 -0800
Message-ID: <20061112213648.e4b91939.akpm@osdl.org>
References: <200611130048.kAD0mduX009385@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, netdev@vger.kernel.org,
	"Michal Pokrywka" <mpokrywka@hoga.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14829 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1753946AbWKMFhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 00:37:12 -0500
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <200611130048.kAD0mduX009385@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 12 Nov 2006 16:48:39 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7502
> 
>            Summary: sunhme not working with 2.6.18 on x86
>     Kernel Version: 2.6.18
>             Status: NEW
>           Severity: normal
>              Owner: jgarzik@pobox.com
>          Submitter: jasmin-bugs@pacifica.ch
> 
> 
> Since Kernel 2.6.18 sunhme gives me a "irq nobody cared" and transmit 
> timeouts. 2.6.17 worked fine. The NIC is a Sun HappyMeal Quad-Port and my 
> architecture is x86.
> 
> The same problem is described at 
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=397460 and it seems the 
> problem is introduced by 
> http://www.kernel.org/git/?p=linux/kernel/git/stable/linux-2.6.18.y.git;a=commit;h=050bbb196392b9c178f82b1205a23dd2f915ee93
> 
> Relevant dmesg part:
> 
> Oct 27 01:12:27 merkur eth0: Link is up using internal transceiver at 100Mb/s, 
> Full Duplex.
> Oct 27 01:12:29 merkur irq 19: nobody cared (try booting with the "irqpoll" 
> option)
> Oct 27 01:12:29 merkur handlers:
> Oct 27 01:12:29 merkur [<0031333e>] (0x31333e)
> Oct 27 01:12:29 merkur Disabling IRQ #19
> Oct 27 01:12:32 merkur eth1: Link is up using internal transceiver at 100Mb/s, 
> Full Duplex.
> Oct 27 01:14:03 merkur NETDEV WATCHDOG: eth1: transmit timed out
> Oct 27 01:14:03 merkur eth1: transmit timed out, resetting
> Oct 27 01:14:03 merkur eth1: Happy Status 03030000 TX[000003ff:00000301]
> 

I'd have expected that this would have been caused by i386 platform
borkage.  But in the debian bug report, Michal has fingered davem's
http://www.kernel.org/git/?p=linux/kernel/git/stable/linux-2.6.18.y.git;a=commit;h=050bbb196392b9c178f82b1205a23dd2f915ee93
as the cause.

Michal, what makes you believe that this particualr patch is to blame?

