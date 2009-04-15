From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 13072] New: forcedeth seems to switch off eth
 on shutdown
Date: Tue, 14 Apr 2009 17:03:26 -0700
Message-ID: <20090414170326.138bf773.akpm@linux-foundation.org>
References: <bug-13072-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org, daniel.bierstedt@gmx.de
To: netdev@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51406 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751823AbZDOAFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2009 20:05:54 -0400
In-Reply-To: <bug-13072-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 12 Apr 2009 07:00:54 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=13072
> 
>            Summary: forcedeth seems to switch off eth on shutdown
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.29.1
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: daniel.bierstedt@gmx.de
>         Regression: No
> 
> 
> Hello,
> 
> I've built a vanilla 2.6.29.1 on a Debian Lenny (stable) system. After
> recognizing that I will not get lirc working on 2.6.29, I wanted to switch back
> to 2.6.28.9. But on any other kernel than 2.6.29.1, the network interface is
> down (no led's no link).
> Ifconfig on 2.6.28.9 is reporting "no link" for eth0, so the driver seems to be
> loaded fine...
> 
> The forcedeth from 2.6.29.1 seems to "shut down" the interface on shutdown, so
> no other kernel can use it.
> 

Seems to be a 2.6.28->2.6.29 regression.
