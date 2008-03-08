From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10201] New: Yum update of Kernel broke sis900
 ethernet driver
Date: Sat, 8 Mar 2008 15:50:52 -0800
Message-ID: <20080308155052.81cf3c8b.akpm@linux-foundation.org>
References: <bug-10201-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, dmcnaul@hotmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44321 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750740AbYCHXuz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 18:50:55 -0500
In-Reply-To: <bug-10201-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  8 Mar 2008 15:36:55 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10201
> 
>            Summary: Yum update of Kernel broke sis900 ethernet driver
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.24.3-12.fc8.i686
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: dmcnaul@hotmail.com
> 
> 
> Latest working kernel version:  2.6.23.15-137.fc8.i686
> Earliest failing kernel version: 2.6.24.3-12.fc8.i686
> Distribution:  Fedora Core 8
> Hardware Environment:  PC
> Software Environment:  Following YUM update
> Problem Description:  After reboot following YUM update to new kernel - SiS 900
> PCI Fast Ethernet (driver sis900) can not ifconfig eth0.  Configuration fails
> with  message "SIOCSIFFLAGS: Invalid argument".  System does boot.  SO  To
> recover, insert FC8 DVD and copy original kernel RPM's to the hard drive.  Then
> install the old Kernel with "rpm -ivh --force --hash *.rpm" and reboot.  System
> comes up and configures the sis900 eth0 correctly at startup.
> 
> Steps to reproduce:  A machine with a SiS 900 PCI Fast Ethernet installed. 
> INstall RC8 and apply the updates.  After 2.6.24.3, reboot and notice the
> trouble.
> 

Apparently a regression.  I seem to recall having seen reports of this
before.

What could cuase SIOCSIFFLAGS to newly return -EINVAL?
