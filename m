From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12432] New: [2.6.28 regression] sis900 fast
 ethernet breakage
Date: Sun, 11 Jan 2009 11:39:56 -0800
Message-ID: <20090111113956.b5c75e83.akpm@linux-foundation.org>
References: <bug-12432-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, gionnico@email.it
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43887 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750905AbZAKTkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 14:40:31 -0500
In-Reply-To: <bug-12432-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 11 Jan 2009 11:00:58 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12432
> 
>            Summary: [2.6.28 regression] sis900 fast ethernet breakage
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.28
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: gionnico@email.it
> 
> 
> Latest working kernel version: 2.6.27
> Earliest failing kernel version: 2.6.28
> Distribution: gentoo
> Hardware Environment: i686, sis900 ethernet
> Problem Description: i can't reach the machine anymore, since i've installed
> 2.6.28 vanilla. it worked in 2.6.27 with the same configuration.
> 
> Steps to reproduce:
> You need a sis900 ethernet and even if you set an ip, the machine doesn't
> respond anymore to the net.
> I tried assigning a dynamic ip with dhcpcd eth0 and i'll post the dmesg.

It's a regression and I'm not seeing any likely-looking changes to that
driver in 2.6.28.

