From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 16:06:34 +0200
Message-ID: <200804181606.34853.mb@bu3sch.de>
References: <bug-10473-10286@http.bugzilla.kernel.org/> <20080417171215.f7fbba3b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	naoliv@gmail.com, Gary Zambrano <zambrano@broadcom.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:51356 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbYDROG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 10:06:58 -0400
In-Reply-To: <20080417171215.f7fbba3b.akpm@linux-foundation.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CCed Gary (the b44 maintainer).
Not sure why I am actually CCed :)


On Friday 18 April 2008 02:12:15 Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 17 Apr 2008 17:08:27 -0700 (PDT)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
> > http://bugzilla.kernel.org/show_bug.cgi?id=10473
> > 
> >            Summary: Infinite loop "b44: eth0: powering down PHY"
> >            Product: Drivers
> >            Version: 2.5
> >      KernelVersion: 2.6.25
> >           Platform: All
> >         OS/Version: Linux
> >               Tree: Mainline
> >             Status: NEW
> >           Severity: high
> >           Priority: P1
> >          Component: Network
> >         AssignedTo: jgarzik@pobox.com
> >         ReportedBy: naoliv@gmail.com
> > 
> > 
> > Latest working kernel version: 2.6.24.4 (from Debian)
> > Earliest failing kernel version: 2.6.25 (vanilla)
> > Distribution: Debian
> > Problem Description:
> > 
> > While booting the new 2.6.25 Kernel, it enters an infinite looping displaying
> > "b44: eth0: powering down PHY".
> > The system isn't freezed as magick SysRq keys works, but it just stay
> > displaying those messages. I am unable to dump any information using SysRq,
> > however (as the b44(...) messages are too fast).
> > 
> > I will attach lspci output and my .config
> > 
> 
> Apparently a regression.

Can you add a dump_stack() call to the b44_halt() function and post the resulting logs?

-- 
Greetings Michael.
