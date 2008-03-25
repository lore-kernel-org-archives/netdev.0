From: "Denys" <nuclearcat@nuclearcat.com>
Subject: Re: [Bugme-new] [Bug 10324] New: kernel panic ip_route_input
Date: Wed, 26 Mar 2008 01:06:58 +0200
Message-ID: <20080325225844.M82705@nuclearcat.com>
References: <bug-10324-10286@http.bugzilla.kernel.org/> <20080325130302.d3f6757c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: bugme-daemon@bugzilla.kernel.org, "Rafael J. Wysocki" <rjw@sisk.pl>
To: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:59280 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755834AbYCYXHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2008 19:07:17 -0400
In-Reply-To: <20080325130302.d3f6757c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I upload whole netconsole file at
http://www.nuclearcat.com/files/ip_route_input_crash.txt 
There is two crashes.



On Tue, 25 Mar 2008 13:03:02 -0700, Andrew Morton wrote
> (switched to email.  Please respond via emailed reply-to-all, not 
> via the bugzilla web interface).
> 
> On Tue, 25 Mar 2008 12:48:37 -0700 (PDT)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=10324
> > 
> >            Summary: kernel panic ip_route_input
> >            Product: Networking
> >            Version: 2.5
> >      KernelVersion: 2.6.25-rc6-git6
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: IPV4
> >         AssignedTo: shemminger@linux-foundation.org
> >         ReportedBy: nuclearcat@nuclearcat.com
> > 
> > 
> > Latest working kernel version: 2.6.24.x
> > Earliest failing kernel version: 2.6.25-rc6
> 
> A post-2.6.24 regression.
> 
> > Distribution: Custom
> > Hardware Environment: Dual CPU, e100 + e1000
> > Software Environment: Custom build. FIB_TRIE enabled
> > Problem Description: Kernel panic after few seconds running network on heavy
> > traffic (around 350 Mbps). 
> > 
> > Steps to reproduce: It is complicated configuration. I can provide whole image
> > of system, around 128MB (it is semi-embedded), but it will need at least few
> > traffic generators similar to mine. So it is difficult to reproduce. I can
> > apply any patches required, but highly prefferable if they dont make server
> > unreachable. I have panic and oops autoreboot sysctl options, nmi-watchdog and
> > software watchdog enabled.
> > I think it is critical to fix this bug before releasing 2.6.25.
> > 
> > Here is latest message with panic:
> > CONFIG_DEBUG_RODATA, 4K stacks, Frame pointers, CONFIG_DEBUG_STACKOVERFLOW - 
> > enabled.
> > 
> > It reboots recently after bringing up networking. Sometimes even not reaching 
> > place where i am loading netconsole.
> > 
> > Always in ip_route_input. This is 2.6.25-rc6-git6, 2 panic's. They are easy 
> > to reproduce, but i cannot do bisect, cause this machine dont have power 
> > switch and in difficult to reach area.
> >
> 
> I've snipped the log output - it was such a wordwrapped mess :(
> 
> Can you please resend it in a reply-to-all to this email, after ensuring
> that it won't be wordwrapped?
> 
> Thanks.


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

