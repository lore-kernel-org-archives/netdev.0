From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12515] New: possible circular locking #0:
 (sk_lock-AF_PACKET){--..}, at: [<c1279838>] sock_setsockopt+0x12b/0x4a4
Date: Tue, 27 Jan 2009 13:43:42 -0800
Message-ID: <20090127134342.e24b158c.akpm@linux-foundation.org>
References: <bug-12515-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, mmokrejs@ribosome.natur.cuni.cz,
	Vegard Nossum <vegard.nossum@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49561 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751799AbZA0Vol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 16:44:41 -0500
In-Reply-To: <bug-12515-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Tue, 20 Jan 2009 10:16:38 -0800 (PST)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12515
> 
>            Summary: possible circular locking #0:  (sk_lock-AF_PACKET){--
>                     ..}, at: [<c1279838>] sock_setsockopt+0x12b/0x4a4
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.29-rc1-git4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: mmokrejs@ribosome.natur.cuni.cz
> 
> 
> Latest working kernel version:
> Earliest failing kernel version:
> Distribution: Gentoo Linux
> Hardware Environment: ASUS L3C/S laptop
> Software Environment:
> Problem Description:
> 
> Steps to reproduce: I have been reinstalling some apps while started tcpdump.
> It immediately hit the bug.
> 

More info at the link.  Vegard did some analysis, had a shot at fixing
it, but it seems that he missed.

