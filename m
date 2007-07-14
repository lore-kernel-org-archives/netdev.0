From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8754] New: Kernel addrconf modifies MTU of
 non-kernel routes
Date: Sat, 14 Jul 2007 15:09:08 -0700
Message-ID: <20070714150908.093eefdb.akpm@linux-foundation.org>
References: <bug-8754-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla@fire.lp0.eu
To: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48079 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1763278AbXGNWJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 18:09:31 -0400
In-Reply-To: <bug-8754-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 14 Jul 2007 14:54:32 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8754
> 
>            Summary: Kernel addrconf modifies MTU of non-kernel routes
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: bugzilla@fire.lp0.eu
> 
> 
> I have an MTU of 16110 set on eth0 on a network where the MTU is 1500 as set by
> RAs. One of the other hosts on the network has an MRU/MTU of 7200 so I have a
> specific route to it with this MTU.
> 
> If I add the route early (i.e. on startup) before address autoconfiguration
> takes place, when the first RA is received the kernel changes the MTU on my
> route - this should not happen.
> 
