From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 11752] New: Extremely low netperf UDP_RR
 throughput for nvidia MCP65
Date: Thu, 16 Oct 2008 13:49:20 -0700
Message-ID: <20081016134920.1492cdcc.akpm@linux-foundation.org>
References: <bug-11752-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, arno@heho.snv.jussieu.fr,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36348 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754579AbYJPUuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 16:50:14 -0400
In-Reply-To: <bug-11752-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Mon, 13 Oct 2008 13:41:19 -0700 (PDT)
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=11752
> 
>            Summary: Extremely low netperf UDP_RR throughput for nvidia MCP65
>            Product: Drivers
>            Version: 2.5
>      KernelVersion: from F10-Beta-x86_64-Live-KDE.iso
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: jgarzik@pobox.com
>         ReportedBy: arno@heho.snv.jussieu.fr
> 
> 
> Latest working kernel version: -
> Earliest failing kernel version:
> Distribution: F10-Beta-x86_64
> Hardware Environment: HP Pavillon dv6820ef
> Software Environment:
> Problem Description: when running at 1Gbps netperf shows good performance for
> TCP_STREAM and UDP_STREAM tests, but extremely bad performance for UDP_RR test
> (less then 1 ping-pong a second whereas at 100Mbps performance easily reaches
> 10-20K a second)
> 
> A friend figured out that it looks like small packets at 1Gbps are dropped
> as being falsely considered crc-errored.
> 
> 
> 
> Steps to reproduce:

Which driver is this using?  forcedeth?
