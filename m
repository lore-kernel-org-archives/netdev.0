From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 9914] New: bnx2 driver of latest kernel 2.6.24
 not working with Cisco catalyst 650x Switch
Date: Thu, 7 Feb 2008 23:18:18 -0800
Message-ID: <20080207231818.cdee64a3.akpm@linux-foundation.org>
References: <bug-9914-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org
To: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47545 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755327AbYBHHSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 02:18:03 -0500
In-Reply-To: <bug-9914-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  7 Feb 2008 23:06:55 -0800 (PST) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=9914
> 
>            Summary: bnx2 driver of latest kernel 2.6.24 not working with
>                     Cisco catalyst 650x Switch
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: 2.6.24
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: kaccountsend@gmail.com
> 
> 
> Latest working kernel version: (Works with Redhat 4 kernel)
> Earliest failing kernel version: 2.6.24
> Distribution: Self, kernel.org's kernel version 2.6.24
> Hardware Environment: Dell 2950
> Software Environment: Linux from Scratch, kernel version 2.6.24
> 
> Problem Description:
> I am using the latest kernel 2.6.24. The hardware unit is a 2950 Dell box.
> The firmware version of bnx2 is 2.9.1. The bnx2 driver does work with other
> flavors of Cisco Switches like 290x. It is having problems at a customer site
> who has a Cisco 650x.
> 
> The customer tried the RHEL 4 and does seem to work fine. The RHEL4 comes with
> the version of bnx2: 1.4.38
> 
> The version on 2.6.24 is 1.6.9.
> 
> Can anyone give me pointers as to why this is broken? Where can I get a patch? 
> 
> Any help is appreciated.
> 
> 
> 
> 
> Steps to reproduce:
> The driver does not auto-negotiate, neither does it work with a fixed link
> speed.
> 
