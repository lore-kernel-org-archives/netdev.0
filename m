From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 10739] New: PPPoE not working, if ethernet
 wire not plugged during boot
Date: Sat, 17 May 2008 22:10:18 -0700
Message-ID: <20080517221018.0a31f9df.akpm@linux-foundation.org>
References: <bug-10739-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	mostrows@speakeasy.net
To: for.dev.null@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38317 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750875AbYERFK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 01:10:26 -0400
In-Reply-To: <bug-10739-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sat, 17 May 2008 21:56:36 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=10739
> 
>            Summary: PPPoE not working, if ethernet wire not plugged during
>                     boot
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.22-14-generic
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: for.dev.null@gmail.com
> 
> 
> Latest working kernel version:
> 
> Earliest failing kernel version:
> 
> Distribution:Ubuntu Gutsy and Hardy
> 
> Hardware Environment:DFE-538TX 10/100 Ethernet Adapter
> RTL8139 Ethernet
> 
> 
> Software Environment:
> Problem Description:
> 
> Steps to reproduce:
> 1. Shutdown machine
> 2. Unplug network wire
> 3. Restart machine
> 4. Wait for complete boot and login
> 5. Plug the network wire **
> 6. Run pppoe-discovery, pppoe-start
> 7. Cannot discovery any access concentrators / servers
> 8. Shutdown
> 9. Keep the network wire plugged
> 10. Start machine and boot
> 11. Wait for complete boot and login
> 12. Run pppoe-discovery, pppoe-start - Works this time !
> 
> The network wire has to be kept connected during boot to use the
> pppoe-discovery command. If the network wire is plugged in later - the
> network/pppoe fails to work.

2.6.22 is awfully old in terms of kernel.org development.  Are you able
to determine whether more recent kernels have the same problem?

This could be dependent upon the devidce driver which is in use. 
Please provide details about the physical layer?
