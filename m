From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9816] New: cannot replace route
Date: Fri, 25 Jan 2008 14:26:03 -0800
Message-ID: <20080125142603.a73fd7a2.akpm@linux-foundation.org>
References: <bug-9816-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, schwab@suse.de
To: netdev@vger.kernel.org, Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52269 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755160AbYAYW0d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2008 17:26:33 -0500
In-Reply-To: <bug-9816-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Fri, 25 Jan 2008 13:23:49 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=9816
> 
>            Summary: cannot replace route
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.24
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: schwab@suse.de
> 
> 
> Latest working kernel version: 2.6.24-rc8
> Earliest failing kernel version: 2.6.24
> Distribution: SuSE 10.3
> Hardware Environment: ppc32/ppc64
> Software Environment:
> Problem Description:
> ip route replace always fails with EEXIST.  (del+add still works.)
> 
> Steps to reproduce:
> # ip ro show 127.0.0.0/8
> 127.0.0.0/8 dev lo  scope link 
> # ip ro rep 127.0.0.0/8 dev lo
> RTNETLINK answers: File exists
> 
> Broken by bd566e7525b5986864e8d6eb5b67640abcd284a9.
> 

There is a bit more discussion in the bugzilla writeup.

I'd agree with Andrea: replacing a route with itself a) used to work and b)
should still work (surely)?

