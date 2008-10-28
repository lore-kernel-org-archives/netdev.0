From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11855] New: kernel BUG when bringing down ppp
 connection
Date: Mon, 27 Oct 2008 20:24:07 -0700
Message-ID: <20081027202407.7e390191.akpm@linux-foundation.org>
References: <bug-11855-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, bluesloth600@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35759 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751921AbYJ1DYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 23:24:46 -0400
In-Reply-To: <bug-11855-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 25 Oct 2008 17:34:16 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11855
> 
>            Summary: kernel BUG when bringing down ppp connection
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.27.3
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: bluesloth600@gmail.com
> 
> 
> Latest working kernel version: 2.6.26.6
> Earliest failing kernel version: 2.6.27

A regression.

> Distribution: Debian sid
> Hardware Environment: Dell Inspiron 1721, AMD x86-64 SMP
> Software Environment:
> Gnu C                  4.3.2
> Gnu make               3.81
> binutils               2.18.0.20080103
> util-linux             2.13.1.1
> mount                  2.13.1.1
> module-init-tools      found
> Linux C Library        2.7
> Dynamic linker (ldd)   2.7
> Procps                 3.2.7
> Console-tools          0.2.3
> Sh-utils               6.10
> udev                   125
> 
> Problem Description: I connect to my dialup service with a Zoom model 3048
> modem connected via a Radio Shack 26-183 USB/serial converter cable.  When I
> log off (using poff), sometimes it works perfectly, but usually after the modem
> disconnects I get:
> 
> kernel BUG at drivers/char/tty_ldisc.c:199!
> invalid opcode: 0000 [1] PREEMPT SMP
> CPU 1

This has an Alany feel to it?

> and then 12 screenfuls of stack traces and stuff, with a bunch of "scheduling
> while atomic" BUGs.. none of it ever managed to get in any logs, so I'll be
> attaching photos of the screen.
> 
> At this point, sometimes the magic SysRq key combinations work, but usually
> they don't, and I have to just turn the computer off.
> 
> I reproduced this with 2.6.27.2 and 2.6.27.3, and then with 2.6.27 using a
> configuration closer to the one I use for 2.6.26.6.
> 
> I set the severity to high because this makes 2.6.27 unusable for me.
> 
> Steps to reproduce: hmm, guess I already said that.

Additional details are attached to the bugzilla report.
