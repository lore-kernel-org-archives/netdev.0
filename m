From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10801] New: niu Sun Neptune 10G fiber card -
 "transmit timed out".
Date: Mon, 26 May 2008 12:52:02 -0700
Message-ID: <20080526125202.3d7cd1fc.akpm@linux-foundation.org>
References: <bug-10801-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org,
	Matheos Worku <matheos.worku@sun.com>, jesper@krogh.cc
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:55101 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752848AbYEZTwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 15:52:10 -0400
In-Reply-To: <bug-10801-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 26 May 2008 12:42:18 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10801
> 
>            Summary: niu Sun Neptune 10G fiber card - "transmit timed out".
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.25.2
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: jesper@krogh.cc
> 
> 
> Latest working kernel version: ? 
> Earliest failing kernel version: 2.6.24 (perhaps earlier)
> Distribution: Ubuntu Hardy 
> Hardware Environment: Sun Fire X4600 M2
> Software Environment:
> Problem Description:
> The driver locks up the kernel and only a hard reboot can bring the system bag.
> only message in the log is:
> May 26 10:51:14 hest kernel: [1477079.785404] NETDEV WATCHDOG: eth4: transmit
> timed out
> .. many times pr. second. 
> 
> Steps to reproduce:
> It seems to be reproducible by sending a lot of traffic (small packages)
> through the card. But I've also hit it under normal production (an NFS server). 
> 
> Discussion: 
> http://thread.gmane.org/gmane.linux.kernel/677545
> 

