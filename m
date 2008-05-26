From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10800] New: Hard lock up after removing
 forcedeth module
Date: Mon, 26 May 2008 12:11:52 -0700
Message-ID: <20080526121152.1f9ab044.akpm@linux-foundation.org>
References: <bug-10800-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: t.artem@mailcity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44608 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754785AbYEZTM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 15:12:29 -0400
In-Reply-To: <bug-10800-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 26 May 2008 11:42:31 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10800
> 
>            Summary: Hard lock up after removing forcedeth module
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.25.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: t.artem@mailcity.com
> 
> 
> Latest working kernel version: haven't tested
> Earliest failing kernel version: haven't tested
> Distribution: Fedora 8
> Hardware Environment: 00:07.0 Bridge: nVidia Corporation MCP61 Ethernet (rev
> a2), nVidia Corporation MCP61 based mobo
> Software Environment: n/a
> Problem Description: rmmod forcedeth causes instant hard lock-up
> 
> Steps to reproduce: boot the PC, put it to the software suspend, wake it up, #
> rmmod forcedeth.
> 

Is the suspend/resume operation a required step to make this occur?  I
assume so.

Do you know if this is a regression?  In other words, did any earlier
kernel perform these steps without crashing the machine?

Thanks.
