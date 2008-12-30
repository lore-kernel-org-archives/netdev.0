From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 12327] New: Intermittent TCP issues with =>
 2.6.27
Date: Mon, 29 Dec 2008 21:41:01 -0800
Message-ID: <20081229214101.4c4f5ac1.akpm@linux-foundation.org>
References: <bug-12327-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, speedster@haveacry.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50789 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751052AbYL3FlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 00:41:10 -0500
In-Reply-To: <bug-12327-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 29 Dec 2008 18:52:40 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=12327
> 
>            Summary: Intermittent TCP issues with => 2.6.27
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.27
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: speedster@haveacry.com
> 
> 
> Latest working kernel version: 2.6.26.8
> Earliest failing kernel version: 2.6.27
> Distribution: Ubuntu
> Hardware Environment: amd64, KVM
> Software Environment:
> Problem Description:
> 
> As reported in LP #296767
> (https://bugs.launchpad.net/ubuntu/+source/linux/+bug/296767) I am experiencing
> intermittent TCP issues over a PPP ADSL2+ connection with the only change being
> an upgrade to 2.6.27.
> 
> A number of websites, ping, traceroute work correctly but I simply can't
> connect to several including:
> 
> - store.apple.com
> - youtube.com
> - ANZ internet banking (anz.com.au)
> - MSN messenger
> 
> I have also tried compiling a generic 2.6.28-rc4 kernel and this still suffers
> from the same issue, however if I reboot into the previous Ubuntu kernel
> (2.6.24) or a vanilla 2.6.26 kernel the issue disappears.
> 
> Steps to reproduce:
> 
> 1. Use a KVM guest as a gateway to a PPP internet connection
> 2. Boot with kernel <= 2.6.26
> 3. Observe functioning networking
> 4. Boot into 2.6.27+
> 5. Observe broken networking

