From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [Bugme-new] [Bug 11536] New: WARNING: at net/ipv4/tcp_input.c:2569
 tcp_ack+0xcd9/0x1f90()
Date: Fri, 12 Sep 2008 13:01:13 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0809121254310.1034@wrl-59.cs.helsinki.fi>
References: <bug-11536-10286@http.bugzilla.kernel.org/>
 <20080911011747.7866aa73.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org,
	lexpublic@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52210 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753274AbYILKB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 06:01:26 -0400
In-Reply-To: <20080911011747.7866aa73.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Sep 2008, Andrew Morton wrote:

> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 11 Sep 2008 01:12:54 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=11536
> > 
> >            Summary: WARNING: at net/ipv4/tcp_input.c:2569
> >                     tcp_ack+0xcd9/0x1f90()
> >            Product: Networking
> >            Version: 2.5
> >      KernelVersion: 2.6.26.5
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: normal
> >           Priority: P1
> >          Component: Netfilter/Iptables
> >         AssignedTo: networking_netfilter-iptables@kernel-bugs.osdl.org
> >         ReportedBy: lexpublic@gmail.com
> > 
> > 
> > Latest working kernel version: unknown
> > Earliest failing kernel version: unknown
> > Distribution: gentoo x86-64
> > Hardware Environment: 
> > #1 2xQuadra opteron, mcp55 nvidia, forcedeth gigabit network
> > #2 2xQuadra xeon, intel 5000 series, e1000e gigabit network
> > 
> > Software Environment:
> > nginx+haproxy
> > 
> > Problem Description:
> > after 5-10 hours network load I have this backtrace in dmesg:
> > 
> > ------------[ cut here ]------------
> > WARNING: at net/ipv4/tcp_input.c:2569 tcp_ack+0xcd9/0x1f90()

This occurs due to miscount in fackets_out, when detected the state 
inconsistency gets corrected. Even though it's not very dangerous event at 
all I'd like to track it down to keep state clean, I hope you can 
reproduce it at least semi-regularily? ...otherwise we're still out of 
luck with it.

Thanks for the report anyway.

-- 
 i.
